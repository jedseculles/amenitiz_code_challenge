class Cart < ApplicationRecord
  # A cart has many items, and items should be removed if the cart is deleted
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  # Session id helps identify a cart per browsing session
  validates :session_id, presence: true, uniqueness: true, length: { maximum: 255 }

  def add_product(product)
    cart_items.find_or_create_by(product: product)
  end

  def remove_product(product)
    cart_items.find_by(product: product).destroy
  end
  
  def clear
    cart_items.destroy_all
  end
end
