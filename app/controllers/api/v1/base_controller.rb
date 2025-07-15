module Api
  module V1
    class BaseController < ApplicationController
      skip_before_action :verify_authenticity_token
      rescue_from StandardError, with: :handle_api_error
      before_action :authenticate_user
      private

      def handle_api_error _exception
        render json: {errors: [Settings.messages.error.internal_server]},
               status: :internal_server_error
      end

      def authenticate_user
        token = request.headers["Authorization"]&.split(" ")&.last
        payload = JwtService.decode(token)
        unless payload && (@current_user = User.find_by(id: payload["user_id"]))
          render json: {errors: [Settings.messages.token.unauthorized]},
                 status: :unauthorized
        end
      end
    end
  end
end
