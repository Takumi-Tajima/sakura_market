class Food < ApplicationRecord
  IMAGE_THUMBNAIL_SIZE = [400, 300].freeze
  IMAGE_MEDIUM_SIZE = [800, 600].freeze
  IMAGE_MAX_FILE_SIZE = 5.megabytes

  has_one_attached :cover_image do |attachable|
    attachable.variant :thumbnail, resize_to_fit: IMAGE_THUMBNAIL_SIZE
    attachable.variant :medium, resize_to_fit: IMAGE_MEDIUM_SIZE
  end

  has_many :cart_items, dependent: :destroy
  has_many :order_items, dependent: :restrict_with_error

  acts_as_list

  before_destroy :prevent_destroy_if_published

  validates :name, presence: true
  validates :description, presence: true
  validates :price, numericality: { greater_than: 0 }
  validates :published, inclusion: { in: [true, false] }
  validates :cover_image, content_type: %i[png jpg jpeg], size: { less_than: IMAGE_MAX_FILE_SIZE }

  scope :default_order, -> { order(:position) }
  scope :published, -> { where(published: true) }

  def price_with_tax
    BigDecimal(price) * BigDecimal(TaxRate.reduced.to_s)
  end

  private

  def prevent_destroy_if_published
    if published?
      errors.add(:base, :prevent_destroy_if_published)
      throw :abort
    end
  end
end
