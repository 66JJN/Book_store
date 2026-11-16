class BooksController < ApplicationController
  # Guests can browse the store. Add `before_action :authenticate_user!, except: %i[ index show ]`
  # here if an action that needs a login is ever added.

  # Safety net: raise if an action forgets to call authorize / policy_scope
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @categories = policy_scope(Category).order(:name)
    @selected_category_id = params[:category_id].presence
    @query = params[:q].to_s.strip
    @books = policy_scope(Book).includes(:category).in_category(@selected_category_id).search(@query).order(:title)
  end

  def show
    @book = Book.includes(:category).find(params[:id])
    authorize @book
  end
end
