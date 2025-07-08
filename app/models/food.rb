class Food < ApplicationRecord
  validates :name, presence: true
  validates :description, presence: true
  validates :price, numericality: { greater_than: 0 }
  validates :published, inclusion: { in: [true, false] }

  scope :default_order, -> { order(id: :desc) }

  def price_with_tax
    BigDecimal(price) * BigDecimal(TaxRate.default.to_s)
  end
end
