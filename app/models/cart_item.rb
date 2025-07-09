class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :food

  validates :food_id, uniqueness: { scope: :cart_id }
  validates :quantity, numericality: { greater_than: 0 }
end
