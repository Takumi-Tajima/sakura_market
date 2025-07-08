class Food < ApplicationRecord
  has_one_attached :cover_image

  validates :name, presence: true
  validates :description, presence: true
  validates :price, numericality: { greater_than: 0 }
  validates :published, inclusion: { in: [true, false] }
  validates :cover_image, content_type: %i[png jpg jpeg], size: { less_than: 5.megabytes }

  scope :default_order, -> { order(id: :desc) }

  def price_with_tax
    BigDecimal(price) * BigDecimal(TaxRate.default.to_s)
  end
end
