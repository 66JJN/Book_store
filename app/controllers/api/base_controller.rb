class Api::BaseController < ActionController::API
  include ActionController::Cookies
  include Pundit::Authorization

  before_action :require_api_authentication

  # Safety net: raise if an action forgets to call authorize
  after_action :verify_authorized

  rescue_from ActiveRecord::RecordNotFound do
    render json: { error: "Not found" }, status: :not_found
  end

  rescue_from ActionController::ParameterMissing do |error|
    render json: { errors: [ error.message ] }, status: :unprocessable_entity
  end

  rescue_from Pundit::NotAuthorizedError do
    render json: { error: "Admin access is required" }, status: :forbidden
  end

  private

  # Devise keeps the login in the session cookie, so the browser and Bruno share the same login
  def require_api_authentication
    return if user_signed_in?

    render json: { error: "Authentication required" }, status: :unauthorized
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
    { id: user.id, email_address: user.email, role: user.role, created_at: user.created_at }
  end

  def render_errors(record)
    render json: { errors: record.errors.full_messages }, status: :unprocessable_entity
  end
end
