require "test_helper"

class StorefrontTest < ActionDispatch::IntegrationTest
  setup do
    @finance = Category.create!(name: "การเงิน")
    @comics = Category.create!(name: "การ์ตูน")
    @stock = Book.create!(title: "หุ้นมือใหม่", author: "พี่ดิว", isbn: "9780000000001", price: 299, stock: 5,
                          category: @finance, description: "First line\nSecond line", published_on: Date.new(2024, 1, 15),
                          cover_image_url: "https://example.test/cover.jpg")
    @comic = Book.create!(title: "ONE PIECE 1", author: "Oda", isbn: "9780000000002", price: 65, stock: 0, category: @comics)
  end

  test "the home page lists every book with its category and price" do
    get root_url

    assert_response :success
    assert_select "h1", "หนังสือทั้งหมด"
    assert_select "p", text: "พบหนังสือ 2 เล่ม"
    assert_select "li h2 a", count: 2
    assert_select "li", text: /หุ้นมือใหม่.*พี่ดิว.*การเงิน.*\$299\.00/m
  end

  test "only books with a cover show an image" do
    get books_url

    assert_select "img[alt=?][src=?]", "Cover of หุ้นมือใหม่", "https://example.test/cover.jpg"
    assert_select "img[alt=?]", "Cover of ONE PIECE 1", count: 0
  end

  test "every category is a filter link" do
    get books_url

    assert_select "section[aria-label='Book categories'] a", text: "ทั้งหมด"
    assert_select "a[href=?]", books_path(category_id: @finance.id, q: ""), text: "การเงิน"
    assert_select "a[href=?]", books_path(category_id: @comics.id, q: ""), text: "การ์ตูน"
  end

  test "filtering by category shows only that category and a clear link" do
    get books_url(category_id: @comics.id)

    assert_select "p", text: "พบหนังสือ 1 เล่ม"
    assert_select "li h2", text: "ONE PIECE 1"
    assert_select "li h2", text: "หุ้นมือใหม่", count: 0
    assert_select "a", text: "ล้าง"
  end

  test "search keeps the query in the box and trims spaces" do
    get books_url(q: "  oda  ")

    assert_select "li h2", text: "ONE PIECE 1"
    assert_select "input[name=q][value=?]", "oda"
    assert_select "a", text: "ล้าง"
  end

  test "search and category filter work together" do
    get books_url(q: "oda", category_id: @finance.id)

    assert_select "p", text: "ไม่พบหนังสือที่ค้นหา"
    assert_select "input[type=hidden][name=category_id][value=?]", @finance.id.to_s
  end

  test "no clear link without a search or filter" do
    get books_url

    assert_select "a", text: "ล้าง", count: 0
  end

  test "the book page shows every detail" do
    get book_url(@stock)

    assert_response :success
    assert_select "h1", "หุ้นมือใหม่"
    assert_select "p", text: "By พี่ดิว"
    assert_select "p", text: "Category: การเงิน"
    assert_select "p", text: "ISBN: 9780000000001"
    assert_select "p", text: "Published: 2024-01-15"
    assert_select "p", text: "Price: $299.00"
    assert_select "p", text: "In stock: 5"
    # simple_format turns the line break in the description into <br>
    assert_select "p br"
    assert_select "p", text: /First line\s*Second line/
    assert_select "img[alt=?]", "Cover of หุ้นมือใหม่"
  end

  test "a book without a publish date or cover says so" do
    get book_url(@comic)

    assert_select "p", text: "Published: Not specified"
    assert_select "img", count: 0
  end

  test "a missing book is a 404" do
    get book_url(id: 0)

    assert_response :not_found
  end

  test "a signed-in user sees their email and Log out instead of Sign in" do
    sign_in create_user("reader@example.test")
    get books_url

    assert_select "a", text: "reader@example.test"
    assert_select "button", text: "Log out"
    assert_select "a", text: "Sign in", count: 0
  end
end
