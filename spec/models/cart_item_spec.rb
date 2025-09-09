require 'rails_helper'

RSpec.describe CartItem, type: :model do
  # CartItem joins Cart and Product with quantity and a unique index on [cart_id, product_id].
  # We test associations, basic validation expectations, and the unique constraint behavior.

  describe 'associations' do
    it 'belongs to cart and product' do
      cart = Cart.create!(session_id: SecureRandom.uuid)
      product = Product.create!(code: 'A1', name: 'Alpha', base_price: 1.25)
      cart_item = CartItem.create!(cart: cart, product: product, quantity: 2)

      expect(cart_item.cart).to eq(cart)
      expect(cart_item.product).to eq(product)
    end
  end

  describe 'uniqueness at db level' do
    it 'enforces one row per product per cart' do
      cart = Cart.create!(session_id: SecureRandom.uuid)
      product = Product.create!(code: 'B1', name: 'Beta', base_price: 2.50)
      CartItem.create!(cart: cart, product: product, quantity: 1)

      # With a model-level uniqueness validation and a DB unique index,
      # duplicates should be rejected at the app layer first with RecordInvalid.
      expect {
        CartItem.create!(cart: cart, product: product, quantity: 3)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end


