class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  # Ensure sensible quantity values and avoid duplicate rows at app level
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :product_id, uniqueness: { scope: :cart_id }
end
