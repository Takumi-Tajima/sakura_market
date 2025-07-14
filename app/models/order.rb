class Order < ApplicationRecord
  extend Enumerize

  MIN_DELIVERY_DAY = 3
  MAX_DELIVERY_DAY = 14
  DELIVERY_TIME_SLOTS = %w[08-12 12-14 14-16 16-18 18-20 20-21].freeze
  SHIPPING_FEE_PER_BOX = 600
  MAX_ITEMS_PER_BOX = 5.0

  enumerize :delivery_time_slot, in: DELIVERY_TIME_SLOTS

  belongs_to :user
  has_many :order_items, dependent: :destroy

  validates :total_amount, numericality: { greater_than: 0 }
  validates :item_total_amount, numericality: { greater_than: 0 }
  validates :tax_amount, numericality: { greater_than: 0 }
  validates :shipping_fee, numericality: { greater_than: 0 }
  validates :cash_on_delivery_fee, numericality: { greater_than: 0 }
  validates :delivery_time_slot, presence: true
  validates :delivery_on, inclusion: { in: -> { available_delivery_dates } }
  validates :delivery_name, presence: true
  validates :delivery_address, presence: true
  validates :ordered_at, presence: true

  def save_with_order_items_and_delete_cart(cart)
    transaction do
      cart.cart_items.each do |cart_item|
        order_items.build(
          food: cart_item.food,
          quantity: cart_item.quantity,
          price: cart_item.food.price_with_tax
        )
      end

      self.ordered_at = Time.current
      self.delivery_name = user.name
      self.delivery_address = user.address

      self.item_total_amount = cart.total_price_with_tax
      self.shipping_fee = calculate_shipping_fee(cart)
      self.cash_on_delivery_fee = calculate_cash_on_delivery_fee(item_total_amount)
      self.tax_amount = cart.total_tax_amount + calculate_service_fees_tax_amount
      self.total_amount = item_total_amount + shipping_fee + cash_on_delivery_fee + tax_amount

      if save
        begin
          cart.destroy!
          true
        rescue StandardError
          errors.add(:base, :cart_processing_error)
          raise ActiveRecord::Rollback
        end
      else
        false
      end
    end
  end

  def calculate_cash_on_delivery_fee(total_amount)
    case total_amount
    when 0...10_000
      300
    when 10_000...30_000
      400
    when 30_000...100_000
      600
    else
      1_000
    end
  end

  def calculate_shipping_fee(cart)
    total_quantity = cart.cart_items.sum(:quantity)
    (total_quantity / MAX_ITEMS_PER_BOX).ceil * SHIPPING_FEE_PER_BOX
  end

  def self.available_delivery_dates
    (MIN_DELIVERY_DAY..MAX_DELIVERY_DAY).filter_map do |days|
      date = Date.current + days
      date if date.on_weekday?
    end
  end

  private

  def calculate_service_fees_tax_amount
    TaxRate.calculate_tax_amount(shipping_fee + cash_on_delivery_fee)
  end
end
