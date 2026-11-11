class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: %i[edit update destroy]

  def index
    @users = User.order(:email_address)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to admin_users_path, notice: "User created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @user.update(user_params)
      redirect_to admin_users_path, notice: "User updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user == current_user
      redirect_to admin_users_path, alert: "You cannot delete your own account.", status: :see_other
    else
      @user.destroy!
      redirect_to admin_users_path, notice: "User deleted successfully.", status: :see_other
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    permitted = params.require(:user).permit(:email_address, :password, :password_confirmation, :role)
    permitted.delete(:password) if permitted[:password].blank?
    permitted.delete(:password_confirmation) if permitted[:password_confirmation].blank?
    permitted
  end
end
