class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :food

  validates :food_id, uniqueness: { scope: :order_id }
  validates :quantity, numericality: { greater_than: 0 }
  validates :price, numericality: { greater_than: 0 }
  validate :validate_food_is_published

  def total_price
    quantity * food.price
  end

  def total_price_with_tax
    quantity * price
  end

  private

  def validate_food_is_published
    unless food.published?
      errors.add(:food, :food_not_available, name: food.name)
    end
  end
end
