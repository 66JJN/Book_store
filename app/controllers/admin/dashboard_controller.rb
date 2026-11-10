class Admin::DashboardController < Admin::BaseController
  def index
    @book_count = Book.count
    @category_count = Category.count
  end
end
