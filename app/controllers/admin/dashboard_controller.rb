class Admin::DashboardController < Admin::BaseController
  def index
    @book_count = Book.count
    @category_count = Category.count
    @market_count = Market.count
    @user_count = User.count
  end
end
