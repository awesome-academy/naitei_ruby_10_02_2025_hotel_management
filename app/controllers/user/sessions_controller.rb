class User::SessionsController < Devise::SessionsController
  layout "application"

  protected

  def after_sign_in_path_for resource
    flash[:success] =
      t("devise.sessions.signed_in", name: resource.usename || resource.email)
    super
  end

  def after_sign_out_path_for resource_or_scope
    flash[:success] = t("devise.sessions.signed_out")
    super
  end
end
