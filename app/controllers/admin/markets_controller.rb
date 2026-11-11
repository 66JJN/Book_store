class Admin::MarketsController < Admin::BaseController
  before_action :set_market, only: %i[edit update destroy]

  def index
    @markets = Market.includes(:books).order(:name)
  end

  def new
    @market = Market.new
  end

  def create
    @market = Market.new(market_params)
    if @market.save
      redirect_to admin_markets_path, notice: "Market created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @market.update(market_params)
      redirect_to admin_markets_path, notice: "Market updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @market.destroy
      redirect_to admin_markets_path, notice: "Market deleted successfully.", status: :see_other
    else
      redirect_to admin_markets_path, alert: @market.errors.full_messages.to_sentence, status: :see_other
    end
  end

  private

  def set_market = @market = Market.find(params[:id])
  def market_params = params.require(:market).permit(:name)
end
