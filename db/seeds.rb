# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
categories = %w[Fiction Non-fiction Technology Science History].map do |name|
  Category.find_or_create_by!(name:)
end

admin = User.find_or_initialize_by(email_address: "admin@bookstore.test")
admin.update!(password: "password123", password_confirmation: "password123", role: :admin)

customer = User.find_or_initialize_by(email_address: "reader@bookstore.test")
customer.update!(password: "password123", password_confirmation: "password123", role: :user)

books = [
  ["The Midnight Library", "Matt Haig", "9780525559474", "Fiction", 14.99, 12, "A novel about the choices that shape a life."],
  ["Clean Code", "Robert C. Martin", "9780132350884", "Technology", 39.99, 8, "A practical guide to writing maintainable software."],
  ["A Brief History of Time", "Stephen Hawking", "9780553380163", "Science", 18.50, 15, "An accessible exploration of modern cosmology."],
  ["Sapiens", "Yuval Noah Harari", "9780062316097", "History", 22.00, 10, "A short history of humankind."],
  ["Atomic Habits", "James Clear", "9780735211292", "Non-fiction", 16.99, 20, "Small changes that lead to remarkable results."]
]

books.each do |title, author, isbn, category_name, price, stock, description|
  Book.find_or_initialize_by(isbn:).update!(
    title:, author:, category: categories.find { |category| category.name == category_name },
    price:, stock:, description:
  )
end
