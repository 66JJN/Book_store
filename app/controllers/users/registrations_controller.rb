# Devise's sign up / My account pages, with one extra rule:
# an admin cannot delete their own account here, so the store never loses its last admin by accident.
class Users::RegistrationsController < Devise::RegistrationsController
  before_action :prevent_admin_self_delete, only: :destroy

  private

  def prevent_admin_self_delete
    return unless current_user.admin?

    redirect_to edit_user_registration_path, alert: "Admins cannot delete their own account. Ask another admin to remove your admin role first."
  end
end
