class ServicesController < BaseAdminController
  load_and_authorize_resource

  def index
    @q = Service.ransack(params[:q])
    @pagy, @services = pagy(@q.result(disinct: true),
                            limit: Settings.services.items_per_page)
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

  def service_params
    params.require(:service).permit(Service::PERMITTED_PARAMS)
  end
end
