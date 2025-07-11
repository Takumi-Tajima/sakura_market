class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy

  # TODO: バリデーション追加
  validates :total_amount, numericality: { greater_than: 0 }
  validates :item_total_amount, numericality: { greater_than: 0 }
  validates :tax_amount, numericality: { greater_than: 0 }
  validates :shipping_fee, numericality: { greater_than: 0 }
  validates :cash_on_delivery_fee, numericality: { greater_than: 0 }
  validates :delivery_time_slot, presence: true
  validates :delivery_on, presence: true
  validates :delivery_name, presence: true
  validates :delivery_address, presence: true
  validates :ordered_at, presence: true
  validate :validate_user_have_address

  def save_with_cart_items(cart)
    return false if cart.cart_items.empty?

    transaction do
      self.total_amount = cart.total_price
      self.item_total_amount = cart.total_price_with_tax
      self.tax_amount = cart.total_tax_amount
      self.shipping_fee = 1
      self.cash_on_delivery_fee = 1
      self.ordered_at = Time.current
      self.delivery_on = Date.current
      self.delivery_time_slot = '未定'
      self.delivery_name = user.name
      self.delivery_address = user.address
      save!
      create_order_items(cart)
      cart.cart_items.destroy_all
      true
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Order save failed: #{e.message}"
    false
  end

  private

  def create_order_items(cart)
    cart.cart_items.each do |cart_item|
      order_items.create!(
        food: cart_item.food,
        quantity: cart_item.quantity,
        price: cart_item.food.price_with_tax
      )
  def validate_user_have_address
    if user.address.blank?
      errors.add(:base, :validate_user_have_address)
    end
  end
end
