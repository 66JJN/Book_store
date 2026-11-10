class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(email) { email.strip.downcase }
  enum :role, { user: "user", admin: "admin" }, default: :user

  validates :email_address, presence: true, uniqueness: true
end
