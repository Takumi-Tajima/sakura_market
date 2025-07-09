class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :food

  validates :food_id, uniqueness: { scope: :cart_id }
  validates :quantity, numericality: { greater_than: 0 }

  scope :default_order, -> { order(id: :desc) }

  def total_price
    quantity * food.price_with_tax
  end
end
