module Api
  module V1
    class AuthController < BaseController
      skip_before_action :authenticate_user,
                         only: [:register, :login, :request_password_reset]

      def register
        @user = User.new(user_params)
        if @user.save
          access_token = JwtService.encode(@user.jwt_payload)
          render json: {access_token: access_token},
                 status: :created
        else
          render json: {errors: @user.errors.full_messages},
                 status: :unprocessable_entity
        end
      end

      def login
        user = User.find_by(email: params[:user][:email]&.downcase)
        if user && valid_login?(user)
          set_refresh_token_cookie(user)
          render json: {user: user_response(user),
                        access_token: generate_access_token(user)},
                 status: :ok
        else
          render json: {errors: [Settings.messages.login.failure]},
                 status: :unauthorized
        end
      end

      def logout
        render json: {message: Settings.messages.logout}, status: :ok
      end

      def request_password_reset
        user = User.find_by(email: params[:email].downcase)
        if user
          user.send_reset_password_instructions
          render json: {message: Settings.messages.password.reset_sent},
                 status: :ok
        else
          render json: {errors: [Settings.messages.password.email_not_found]},
                 status: :not_found
        end
      end

      def reset_password
        user = User.reset_password_by_token(reset_password_params)
        if user.errors.empty?
          render json: {message: Settings.messages.password.reset_success},
                 status: :ok
        else
          render json: {errors: user.errors.full_messages},
                 status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.require(:user).permit(User::PERMITTED_ATTRS)
      end

      def reset_password_params
        params.require(:user).permit(:reset_password_token, :password,
                                     :password_confirmation)
      end

      def refresh_token
        token = cookies.encrypted[:refresh_token]
        payload = JwtService.decode(token)
        if payload && (user = User.find_by(id: payload["user_id"]))
          new_access_token = JwtService.encode(
            user.jwt_payload,
            Settings.access_token_time_limit.minutes.from_now
          )
          render json: {token: new_access_token}, status: :ok
        else
          render json: {errors: [Settings.messages.token.invalid_or_expired]},
                 status: :unauthorized
        end
      end

      def user_response user
        user.as_json(only: [:id, :username, :email, :phone, :admin, :activated])
      end

      def valid_login? user
        user.valid_password?(params[:user][:password]) && user.confirmed?
      end

      def generate_access_token user
        JwtService.encode(user.jwt_payload,
                          Settings.access_token_time_limit.minutes.from_now)
      end

      def set_refresh_token_cookie user
        refresh_token = JwtService.encode(
          {user_id: user.id},
          Settings.refresh_token_time_limit.days.from_now
        )
        cookies.encrypted[:refresh_token] = {
          value: refresh_token,
          httponly: true,
          secure: Rails.env.production?,
          expires: Settings.refresh_token_time_limit.days.from_now
        }
      end
    end
  end
end
