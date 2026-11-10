class BooksController < ApplicationController
  def index
    @categories = Category.order(:name)
    @selected_category_id = params[:category_id].presence
    @query = params[:q].to_s.strip
    @books = Book.includes(:category).in_category(@selected_category_id).search(@query).order(:title)
  end

  def show
    @book = Book.includes(:category).find(params[:id])
  end
end
