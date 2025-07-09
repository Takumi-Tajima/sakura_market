class Cart < ApplicationRecord
  belongs_to :user

  has_many :cart_items, dependent: :destroy

  validates :user_id, uniqueness: true

  def total_price
    cart_items.sum(&:total_price)
  end
end
