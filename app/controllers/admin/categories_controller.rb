class Admin::CategoriesController < Admin::BaseController
  before_action :set_category, only: %i[edit update destroy]

  def index
    @categories = Category.includes(:books).order(:name)
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)
    save_or_render(:new, "Category created successfully.")
  end

  def edit; end

  def update
    if @category.update(category_params)
      redirect_to admin_categories_path, notice: "Category updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @category.destroy
      redirect_to admin_categories_path, notice: "Category deleted successfully.", status: :see_other
    else
      redirect_to admin_categories_path, alert: @category.errors.full_messages.to_sentence, status: :see_other
    end
  end

  private

  def set_category = @category = Category.find(params[:id])
  def category_params = params.require(:category).permit(:name)

  def save_or_render(template, message)
    if @category.save
      redirect_to admin_categories_path, notice: message
    else
      render template, status: :unprocessable_entity
    end
  end
end
