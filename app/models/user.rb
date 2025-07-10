class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :confirmable, :trackable

  has_one :cart, dependent: :destroy
  has_many :orders, dependent: :destroy

  validates :name, presence: true
  validates :address, presence: true
end
