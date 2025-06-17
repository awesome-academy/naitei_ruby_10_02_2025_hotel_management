class RoomTypesController < BaseAdminController
  load_and_authorize_resource class: RoomType, except: %i(destroy_image)
  def index
    @room_types = RoomType.without_deleted
  end

  def new
    @room_type = RoomType.new
    @room_type.devices.build
  end

  def create
    if @room_type.save
      flash[:success] = t "msg.room_type_created"
      redirect_to room_types_path
    else
      @room_type.devices.build if @room_type.devices.empty?
      render :new, status: :unprocessable_entity
    end
  end

  def show; end

  def edit; end

  def update
    if @room_type.update room_type_params
      flash[:success] = t "msg.room_type_updated"
      redirect_to @room_type
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @room_type.destroy
      flash[:success] = t "msg.room_type_deleted"
    else
      flash[:danger] = t "msg.delete_fail"
    end
    redirect_to room_types_url
  end

  def destroy_image
    @room_type = RoomType.find_by id: params[:room_type_id]
    image = @room_type.images.find(params[:image_id])
    image.purge
    flash[:success] = t "msg.image_removed"
    redirect_to edit_room_type_path(@room_type)
  end

  private
  def room_type_params
    params.require(:room_type).permit(*RoomType::PERMITTED_PARAMS)
  end
end
