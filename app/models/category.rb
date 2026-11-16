class Category < ApplicationRecord
  has_many :books, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true

  def self.ransackable_attributes(_auth_object = nil)
    %w[name created_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[books]
  end
end
