# frozen_string_literal: true

ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    div class: "grid gap-4 md:grid-cols-4 mb-8" do
      [
        [ "Books", Book.count, admin_books_path ],
        [ "Categories", Category.count, admin_categories_path ],
        [ "Markets", Market.count, admin_markets_path ],
        [ "Users", User.count, admin_users_path ]
      ].each do |label, value, path|
        a href: path, class: "block rounded-lg border border-gray-200 dark:border-gray-800 p-4 hover:bg-gray-50 dark:hover:bg-gray-800" do
          para label, class: "text-sm text-gray-500"
          para value.to_s, class: "text-3xl font-semibold"
        end
      end
    end

    # v4 has no columns/column helpers any more: lay the panels out with Tailwind
    div class: "grid gap-4 lg:grid-cols-2" do
      div do
        panel "Low stock (5 or fewer)" do
          table_for Book.includes(:category).where(stock: ..5).order(:stock, :title).limit(10) do
            column(:title) { |book| link_to book.title, admin_book_path(book) }
            column :category
            column :stock
          end
        end
      end

      div do
        panel "Recently added books" do
          table_for Book.includes(:category).order(created_at: :desc).limit(5) do
            column(:title) { |book| link_to book.title, admin_book_path(book) }
            column :category
            column(:price) { |book| number_to_currency(book.price) }
          end
        end
      end
    end
  end
end
