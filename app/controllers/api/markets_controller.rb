class Api::MarketsController < Api::BaseController
  before_action :require_api_admin, only: %i[create update destroy]
  before_action :set_market, only: %i[show update destroy]

  def index
    render json: { markets: Market.order(:name).map { |market| market_json(market) } }
  end

  def show
    render json: { market: market_json(@market) }
  end

  def create
    market = Market.new(market_params)
    return render_errors(market) unless market.save

    render json: { market: market_json(market) }, status: :created
  end

  def update
    return render_errors(@market) unless @market.update(market_params)

    render json: { market: market_json(@market) }
  end

  def destroy
    return render_errors(@market) unless @market.destroy

    head :no_content
  end

  private

  def set_market = @market = Market.find(params[:id])
  def market_params = params.require(:market).permit(:name)
end
