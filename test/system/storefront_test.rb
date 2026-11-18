require "application_system_test_case"

class StorefrontSystemTest < ApplicationSystemTestCase
  setup do
    finance = Category.create!(name: "การเงิน")
    @comics = Category.create!(name: "การ์ตูน")
    @stock_book = Book.create!(title: "หุ้นมือใหม่", author: "พี่ดิว", isbn: "9780000000001", price: 299, stock: 5, category: finance)
    Book.create!(title: "ONE PIECE 1", author: "Oda", isbn: "9780000000002", price: 65, stock: 3, category: @comics)
  end

  test "a guest browses the store and opens a book" do
    visit root_path

    assert_selector "h1", text: "หนังสือทั้งหมด"
    assert_text "พบหนังสือ 2 เล่ม"

    click_on "หุ้นมือใหม่"
    assert_selector "h1", text: "หุ้นมือใหม่"
    assert_text "By พี่ดิว"
    assert_text "Price: $299.00"
    assert_no_link "Edit in admin"

    click_on "Back to books"
    assert_selector "h1", text: "หนังสือทั้งหมด"
  end

  test "a guest searches for a book and clears the search" do
    visit root_path

    fill_in "ค้นหาหนังสือ", with: "oda"
    click_on "ค้นหา"
    assert_text "พบหนังสือ 1 เล่ม"
    assert_link "ONE PIECE 1"
    assert_no_link "หุ้นมือใหม่"

    click_on "ล้าง"
    assert_text "พบหนังสือ 2 เล่ม"
  end

  test "a search with no match says nothing was found" do
    visit root_path

    fill_in "ค้นหาหนังสือ", with: "no such book"
    click_on "ค้นหา"
    assert_text "ไม่พบหนังสือที่ค้นหา"
  end

  test "a guest filters by category" do
    visit root_path

    within "section[aria-label='Book categories']" do
      click_on "การ์ตูน"
    end
    assert_text "พบหนังสือ 1 เล่ม"
    assert_link "ONE PIECE 1"
    assert_no_link "หุ้นมือใหม่"

    click_on "ทั้งหมด"
    assert_text "พบหนังสือ 2 เล่ม"
  end
end
