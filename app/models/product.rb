class Product < ApplicationRecord
  # Basic catalog validations to ensure data integrity
  validates :code, presence: true, uniqueness: true, length: { maximum: 10 }
  validates :name, presence: true
  validates :base_price, presence: true, numericality: { greater_than: 0 }

  # Convenience scope for active products in the catalog
  scope :active, -> { where(active: true) }

  has_many :cart_items, dependent: :destroy
  has_many :carts, through: :cart_items 
end
