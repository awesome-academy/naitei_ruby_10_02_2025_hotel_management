class ServicesController < BaseAdminController
  before_action :get_service, only: %i(destroy edit update)

  def index
    @pagy, @services = pagy Service.searched(params[:search]),
                            limit: Settings.services.items_per_page
  end

  def new
    @service = Service.new
  end

  def create
    @service = Service.new service_params
    @service.image.attach params.dig(:service, :image)
    if @service.save
      flash[:success] = t "msg.service_created"
      redirect_to services_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    if @service.destroy
      flash[:success] = t "msg.service_deleted"
    else
      flash[:error] = t "msg.service_delete_failed"
    end
    redirect_to services_path
  end

  def edit; end

  def update
    if params.dig(:service, :image)
      @service.image.attach params.dig(:service, :image)
    end

    if @service.update service_params
      flash[:success] = t "msg.service_updated"
      redirect_to services_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
  def get_service
    @service = Service.find_by id: params[:id]
    return if @service

    flash[:error] = t "msg.service_not_found"
    redirect_to services_path
  end

  def service_params
    params.require(:service).permit(Service::PERMITTED_PARAMS)
  end
end
