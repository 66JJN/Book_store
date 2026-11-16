class Api::CategoriesController < Api::BaseController
  before_action :set_category, only: %i[show update destroy]

  def index
    authorize Category
    render json: { categories: policy_scope(Category).order(:name).map { |category| category_json(category) } }
  end

  def show
    render json: { category: category_json(@category) }
  end

  def create
    category = authorize Category.new(category_params)
    return render_errors(category) unless category.save

    render json: { category: category_json(category) }, status: :created
  end

  def update
    return render_errors(@category) unless @category.update(category_params)

    render json: { category: category_json(@category) }
  end

  def destroy
    return render_errors(@category) unless @category.destroy

    head :no_content
  end

  private

  def set_category = @category = authorize(Category.find(params[:id]))
  def category_params = params.require(:category).permit(:name)
end
