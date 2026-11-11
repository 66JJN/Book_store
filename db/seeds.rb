# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
category_names = ["การเงิน", "ตลก", "จิตวิทยา", "การ์ตูนอนิเมะ"]
old_category_names = ["Fiction", "Non-fiction", "Technology", "Science", "History"]

categories = category_names.index_with { |name| Category.find_or_create_by!(name:) }

admin_email = ENV.fetch("ADMIN_EMAIL", "admin@bks.test")
admin_password = ENV.fetch("ADMIN_PASSWORD", "1234")
reader_email = ENV.fetch("READER_EMAIL", "user@bks.test")
reader_password = ENV.fetch("READER_PASSWORD", "1234")

# เปลี่ยน category ของหนังสือข้อมูลตัวอย่างให้ตรงกับหมวดใหม่
book_categories = {
  "9780525559474" => "ตลก",
  "9780132350884" => "การเงิน",
  "9780553380163" => "จิตวิทยา",
  "9780062316097" => "การ์ตูนอนิเมะ",
  "9780735211292" => "จิตวิทยา"
}

admin = User.find_by(email_address: admin_email) || User.find_by(email_address: "admin@bookstore.test") || User.new
admin.email_address = admin_email
admin.update!(password: admin_password, password_confirmation: admin_password, role: :admin)

customer = User.find_by(email_address: reader_email) || User.find_by(email_address: "reader@bookstore.test") || User.new
customer.email_address = reader_email
customer.update!(password: reader_password, password_confirmation: reader_password, role: :user)

books = [
  ["หุ้น CK", "CK Cheong", "9780525559474", "การเงิน", 350.00, 12, "หนังสือพื้นฐานสำหรับคนที่อยากเริ่มศึกษาการลงทุนในหุ้น อ่านง่าย เหมาะกับมือใหม่."],
  ["ลงทุนหุ้นกับพี่ดิว", "พี่ดิว", "9780132350884", "การเงิน", 299.00, 8, "แนวคิดการลงทุนและการวิเคราะห์หุ้นฉบับเข้าใจง่าย พร้อมตัวอย่างสำหรับนักลงทุนมือใหม่."],
  ["ขายหัวเราะ", "บก.ขายหัวเราะ", "9780553380163", "ตลก", 75.00, 15, "รวมการ์ตูนและมุกสนุก ๆ สำหรับอ่านคลายเครียด."],
  ["ONE PIECE", "Eiichiro Oda", "9780062316097", "การ์ตูนอนิเมะ", 95.00, 10, "การผจญภัยของลูฟี่และกลุ่มหมวกฟางในการตามหาสมบัติวันพีซ."],
  ["จิตวิทยาสำหรับชีวิตประจำวัน", "ทีม Book Store", "9780735211292", "จิตวิทยา", 220.00, 20, "เรียนรู้ความคิด อารมณ์ และพฤติกรรมของคน เพื่อนำไปใช้ในชีวิตประจำวัน."]
]

books.each do |title, author, isbn, category_name, price, stock, description|
  Book.find_or_initialize_by(isbn:).update!(
    title:, author:, category: categories.fetch(category_name),
    price:, stock:, description:
  )
end

# ลบเฉพาะหมวดตัวอย่างเดิมที่ไม่มีหนังสือเหลืออยู่
Category.where(name: old_category_names).find_each do |category|
  category.destroy if category.books.empty?
end

market_names = ["ตลาดนัดหนังสือ", "งานสัปดาห์หนังสือ", "ร้านหนังสือออนไลน์"]
markets = market_names.map do |name|
  Market.find_or_create_by!(name:)
end

Book.find_by!(isbn: "9780132350884").markets = [markets[0], markets[2]]
Book.find_by!(isbn: "9780062316097").markets = [markets[0], markets[1]]
Book.find_by!(isbn: "9780735211292").markets = [markets[1], markets[2]]

Market.where(name: ["Central Book Market", "Weekend Book Fair", "Online Book Market"]).find_each do |market|
  market.destroy if market.books.empty?
end
