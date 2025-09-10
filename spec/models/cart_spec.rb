require 'rails_helper'

RSpec.describe Cart, type: :model do
  # Carts hold items and have a unique session_id (per schema).
  # We'll verify associations and simple invariants.

  describe 'database columns' do
    it 'has expected columns' do
      expect(described_class.column_names).to include('session_id')
    end
  end

  describe 'associations' do
    it 'can have many cart_items' do
      cart = Cart.create!(session_id: SecureRandom.uuid)
      product = Product.create!(code: 'X1', name: 'X', base_price: 1.0)
      CartItem.create!(cart: cart, product: product, quantity: 1)

      expect(cart.cart_items.count).to eq(1)
    end
  end
end
