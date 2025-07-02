class User::RegistrationsController < Devise::RegistrationsController
  def create
    super do |resource|
      flash[:success] = t(
        "devise.registrations.signed_up",
        name: resource.username || resource.email
      )
    end
  end

  private

  def sign_up_params
    params.require(:user).permit(User::PERMITTED_ATTRS)
  end

  def account_update_params
    params.require(:user).permit(User::PERMITTED_UPDATE_ATTRS)
  end
end
