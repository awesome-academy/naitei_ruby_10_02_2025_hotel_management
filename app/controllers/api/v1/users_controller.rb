module Api
  module V1
    class UsersController < BaseController
      skip_before_action :authenticate_user, only: [:create]
      before_action :set_user, only: [:show, :update, :destroy]
      before_action :authorize_admin, except: [:create, :show, :update]

      def index
        @users = User.ransack(params[:q]).result
        render json: @users, status: :ok
      end

      def show
        render json: @user, status: :ok
      end

      def create
        @user = User.new(user_params)
        if @user.save
          render json: @user, status: :created
        else
          render json: {errors: @user.errors.full_messages},
                 status: :unprocessable_entity
        end
      end

      def update
        if @user == current_user || current_user.admin?
          if @user.update(user_update_params)
            render json: @user, status: :ok
          else
            render json: {errors: @user.errors.full_messages},
                   status: :unprocessable_entity
          end
        else
          render json: {errors: [Settings.messages.unauthorized]},
                 status: :forbidden
        end
      end

      def destroy
        if current_user.admin?
          if @user.destroy
            render json: {
              message: Settings.messages.user_deleted
            }, status: :ok
          else
            render json: {
              errors: [Settings.messages.error.user_not_deleted]
            }, status: :unprocessable_entity
          end
        else
          render json: {
            errors: [Settings.messages.unauthorized]
          }, status: :forbidden
        end
      end
      private

      def set_user
        @user = User.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: {errors: [Settings.messages.error.user_not_found]},
               status: :not_found
      end

      def user_params
        params.require(:user).permit(User::PERMITTED_ATTRS)
      end

      def user_update_params
        params.require(:user).permit(User::PERMITTED_ATTRS)
      end

      def authorize_admin
        return if current_user.admin?

        render json: {errors: [Settings.messages.unauthorized]},
               status: :forbidden
      end
    end
  end
end
