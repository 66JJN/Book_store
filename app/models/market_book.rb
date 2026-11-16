class MarketBook < ApplicationRecord
  belongs_to :market
  belongs_to :book

  validates :book_id, uniqueness: { scope: :market_id }

  # Needed by the "Markets" filter on the ActiveAdmin books page (it searches through this join model)
  def self.ransackable_attributes(_auth_object = nil)
    %w[market_id book_id]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[market book]
  end
end
