class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :food

  validates :food_id, uniqueness: { scope: :order_id }
  validates :quantity, numericality: { greater_than: 0 }
  validates :price, numericality: { greater_than: 0 }
end
