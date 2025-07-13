class Order < ApplicationRecord
  extend Enumerize

  MINIMUM_DELIVERY_DAYS = 3
  MAXIMUM_DELIVERY_DAYS = 14
  DELIVERY_TIME_ZONES_AVAILABLE = %w[08-12 12-14 14-16 16-18 18-20 20-21].freeze
  SHIPPING_FEE_PER_UNIT = 600

  enumerize :delivery_time_slot, in: DELIVERY_TIME_ZONES_AVAILABLE

  belongs_to :user
  has_many :order_items, dependent: :destroy

  # TODO: バリデーション追加
  validates :total_amount, numericality: { greater_than: 0 }
  validates :item_total_amount, numericality: { greater_than: 0 }
  validates :tax_amount, numericality: { greater_than: 0 }
  validates :shipping_fee, numericality: { greater_than: 0 }
  validates :cash_on_delivery_fee, numericality: { greater_than: 0 }
  validates :delivery_time_slot, presence: true, inclusion: { in: DELIVERY_TIME_ZONES_AVAILABLE }
  validates :delivery_on, presence: true
  validates :delivery_name, presence: true
  validates :delivery_address, presence: true
  validates :ordered_at, presence: true
  validate :validate_delivery_on_is_available

  def save_with_cart_items(cart)
    transaction do
      import_cart_items(cart)
      setup_order_details(cart)
      save!
      cart.destroy!
    end
    true
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Order save failed: #{e.message}"
    errors.add(:base, '注文の作成に失敗しました') if errors.empty?
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

  # TODO: 小数点計算なのでロジックを調査する
  def calculate_shipping_fee(cart)
    total_quantity = cart.cart_items.sum(:quantity)
    (total_quantity / 5.0).ceil * SHIPPING_FEE_PER_UNIT
  end

  private

  def import_cart_items(cart)
    cart.cart_items.find_each do |cart_item|
      order_items.build(
        food: cart_item.food,
        quantity: cart_item.quantity,
        price: cart_item.food.price_with_tax # 注文時点の価格を固定
      )
    end
  end

  def setup_order_details(cart)
    # 商品関連の金額設定
    self.item_total_amount = cart.total_price_with_tax

    # 追加料金の計算
    self.shipping_fee = calculate_shipping_fee(cart)
    self.cash_on_delivery_fee = calculate_cash_on_delivery_fee(item_total_amount)

    # 税金と合計の計算
    setup_tax_and_total_amounts

    # 配送情報の設定
    setup_delivery_info
  end

  def setup_tax_and_total_amounts
    # 送料と代引き手数料の税額
    fees_tax = calculate_fees_tax

    # 総税額 = 商品税額 + 手数料税額
    self.tax_amount = calculate_items_tax + fees_tax

    # 総合計 = 商品合計 + 送料 + 代引き手数料 + 手数料税額
    self.total_amount = item_total_amount + shipping_fee + cash_on_delivery_fee + fees_tax
  end

  def calculate_fees_tax
    ((shipping_fee + cash_on_delivery_fee) * 0.1).floor
  end

  def calculate_items_tax
    order_items.sum { |item| (item.price * item.quantity * 0.1).floor }
  end

  def setup_delivery_info
    self.ordered_at = Time.current
    self.delivery_name = user.name
    self.delivery_address = user.address
  end

  def add_error_and_return_false(attribute, message)
    errors.add(attribute, message)
    false
  end

  def validate_delivery_on_is_available
    available_dates = Order.available_delivery_dates

    unless available_dates.include?(delivery_on)
      errors.add(:delivery_on, '選択可能な配送日を指定してください')
    end
  end
end
