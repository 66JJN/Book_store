class Api::BaseController < ActionController::API
  include ActionController::Cookies

  before_action :require_api_authentication

  rescue_from ActiveRecord::RecordNotFound do
    render json: { error: "Not found" }, status: :not_found
  end

  rescue_from ActionController::ParameterMissing do |error|
    render json: { errors: [error.message] }, status: :unprocessable_entity
  end

  private

  def current_api_user
    Current.session&.user
  end

  def resume_api_session
    Current.session ||= Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
  end

  def require_api_authentication
    return if resume_api_session

    render json: { error: "Authentication required" }, status: :unauthorized
  end

  def require_api_admin
    return if current_api_user&.admin?

    render json: { error: "Admin access is required" }, status: :forbidden
  end

  def book_json(book)
    book.as_json(only: %i[id title author isbn description price stock published_on cover_image_url], include: {
      category: { only: %i[id name] }, markets: { only: %i[id name] }
    })
  end

  def category_json(category)
    category.as_json(only: %i[id name])
  end

  def market_json(market)
    market.as_json(only: %i[id name])
  end

  def user_json(user)
    user.as_json(only: %i[id email_address role created_at])
  end

  def render_errors(record)
    render json: { errors: record.errors.full_messages }, status: :unprocessable_entity
  end
end
