class Api::BooksController < Api::BaseController
  before_action :require_api_admin, only: %i[create update destroy]
  before_action :set_book, only: %i[show update destroy]

  def index
    books = Book.includes(:category, :markets).in_category(params[:category_id]).search(params[:q]).order(:title)
    render json: { books: books.map { |book| book_json(book) } }
  end

  def show
    render json: { book: book_json(@book) }
  end

  def create
    book = Book.new(book_params)
    if book.save
      render json: { book: book_json(book.reload) }, status: :created
    else
      render_errors(book)
    end
  end

  def update
    if @book.update(book_params)
      render json: { book: book_json(@book.reload) }
    else
      render_errors(@book)
    end
  end

  def destroy
    @book.destroy!
    head :no_content
  end

  private

  def set_book = @book = Book.includes(:category, :markets).find(params[:id])

  def book_params
    permitted = params.require(:book).permit(
      :title, :author, :isbn, :description, :price, :stock, :published_on,
      :cover_image_url, :category_id, :category_name, market_ids: [], market_names: []
    )

    if (category_name = permitted.delete(:category_name)).present?
      permitted[:category_id] = Category.find_by(name: category_name)&.id
    end

    if (market_names = permitted.delete(:market_names)).present?
      permitted[:market_ids] = Market.where(name: market_names).pluck(:id)
    end

    permitted
  end
end
