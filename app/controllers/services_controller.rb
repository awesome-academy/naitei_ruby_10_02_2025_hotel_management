class ServicesController < BaseAdminController
  before_action :get_service, only: %i(destroy)

  def index
    @pagy, @services = pagy Service.all, limit: Settings.services.items_per_page
  end

  def destroy
    if @service.destroy
      flash[:success] = t "msg.service_deleted"
    else
      flash[:error] = t "msg.service_delete_failed"
    end
    redirect_to services_path
  end

  private
  def get_service
    @service = Service.find_by id: params[:id]
    return if @service

    flash[:error] = t "msg.service_not_found"
    redirect_to services_path
  end
end
