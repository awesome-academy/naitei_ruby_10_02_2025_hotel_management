module Api
  module V1
    class RequestsController < BaseController
      def create
        authorize! :create, Request
        service = ::RequestService.new(params: request_params,
                                       user: current_user)
        result = service.call

        if result[:request]
          render json: result, status: :created
        else
          render json: {errors: result[:errors]},
                 status: :unprocessable_entity
        end
      end

      private

      def request_params
        params.require(:request).permit(Request::PERMITTED_ATTRS)
      end
    end
  end
end
