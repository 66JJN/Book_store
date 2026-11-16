class Api::UsersController < Api::BaseController
  before_action :set_user, only: %i[show update destroy]

  def index
    authorize User
    render json: { users: User.includes(:roles).order(:email).map { |user| user_json(user) } }
  end

  def show
    render json: { user: user_json(@user) }
  end

  def create
    user = authorize User.new(user_params)
    return render_errors(user) unless user.save

    render json: { user: user_json(user) }, status: :created
  end

  def update
    # An admin must not demote themselves and lose access to the admin API
    if @user == current_user && user_params[:role].present? && user_params[:role] != "admin"
      return render json: { errors: [ "You cannot remove your own admin role" ] }, status: :unprocessable_entity
    end

    return render_errors(@user) unless @user.update(user_params)

    render json: { user: user_json(@user) }
  end

  def destroy
    @user.destroy!
    head :no_content
  end

  private

  def set_user = @user = authorize(User.find(params[:id]))
  def user_params
    permitted = params.require(:user).permit(:email_address, :password, :password_confirmation, :role)
    # Leaving the password out of an update keeps the current one
    permitted.delete(:password) if permitted[:password].blank?
    permitted.delete(:password_confirmation) if permitted[:password_confirmation].blank?
    permitted
  end
end
