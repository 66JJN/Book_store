class Api::UsersController < Api::BaseController
  before_action :require_api_admin
  before_action :set_user, only: %i[show update destroy]

  def index
    render json: { users: User.order(:email_address).map { |user| user_json(user) } }
  end

  def show
    render json: { user: user_json(@user) }
  end

  def create
    user = User.new(user_params)
    return render_errors(user) unless user.save

    render json: { user: user_json(user) }, status: :created
  end

  def update
    return render_errors(@user) unless @user.update(user_params)

    render json: { user: user_json(@user) }
  end

  def destroy
    @user.destroy!
    head :no_content
  end

  private

  def set_user = @user = User.find(params[:id])
  def user_params
    params.require(:user).permit(:email_address, :password, :password_confirmation, :role)
  end
end
