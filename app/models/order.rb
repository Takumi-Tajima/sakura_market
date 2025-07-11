class Order < ApplicationRecord
  MINIMUM_DELIVERY_DAYS = 3
  MAXIMUM_DELIVERY_DAYS = 14

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
  validate :validate_delivery_on_is_available

  def save_with_cart_items(cart)
    return false if cart.cart_items.empty?
    return false if invalid?

    transaction do
      build_order_items_from_cart(cart)
      assign_attributes_from_cart(cart)
      save!
      cart.destroy!
    end
    true
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Order save failed: #{e.message}"
    false
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

  def self.available_delivery_dates
    (MINIMUM_DELIVERY_DAYS..MAXIMUM_DELIVERY_DAYS).map do |days|
      Date.current + days
    end.select(&:on_weekday?)
  end

  private

  def build_order_items_from_cart(cart)
    cart.cart_items.each do |cart_item|
      order_items.build(
        food: cart_item.food,
        quantity: cart_item.quantity,
        price: cart_item.food.price_with_tax
      )
    end
  end

  def assign_attributes_from_cart(cart)
    self.item_total_amount = cart.total_price_with_tax
    self.shipping_fee = 1 # TODO: 送料計算実装予定
    self.cash_on_delivery_fee = calculate_cash_on_delivery_fee(cart.total_price_with_tax)

    calculate_tax_and_total_amounts(cart)
    assign_delivery_attributes
  end

  def calculate_tax_and_total_amounts(cart)
    # 税額計算: 商品税額 + (送料 + 代引き手数料) * 10%
    shipping_and_delivery_tax = calculate_shipping_and_delivery_tax
    self.tax_amount = cart.total_tax_amount + shipping_and_delivery_tax

    # 総合計額 = 商品合計(税込) + 送料(税抜) + 代引き手数料(税抜) + (送料+代引き手数料)の税額
    self.total_amount = item_total_amount + shipping_fee + cash_on_delivery_fee + shipping_and_delivery_tax
  end

  def calculate_shipping_and_delivery_tax
    ((shipping_fee + cash_on_delivery_fee) * 0.1).floor
  end

  def assign_delivery_attributes
    self.ordered_at = Time.current
    self.delivery_on ||= Date.current + MINIMUM_DELIVERY_DAYS
    self.delivery_time_slot = '未定'
    self.delivery_name = user.name
    self.delivery_address = user.address
  end

  def validate_user_have_address
    if user.address.blank?
      errors.add(:base, :validate_user_have_address)
    end
  end

  def validate_delivery_on_is_available
    available_dates = Order.available_delivery_dates

    unless available_dates.include?(delivery_on)
      errors.add(:delivery_on, '選択可能な配送日を指定してください')
    end
  end
end
