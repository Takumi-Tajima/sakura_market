class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :food

  validates :food_id, uniqueness: { scope: :cart_id }
  validates :quantity, numericality: { greater_than: 0 }
  validate :validate_food_is_published

  scope :default_order, -> { order(id: :desc) }

  def total_price
    quantity * food.price
  end

  def total_price_with_tax
    quantity * food.price_with_tax
  end

  private

  def validate_food_is_published
    unless food.published?
      errors.add(:cart_item, :validate_food_is_published)
    end
  end
end
