class User::PasswordsController < Devise::PasswordsController
  def edit
    @reset_password_cta = "devise.passwords.edit.header"
    super
  end
end
