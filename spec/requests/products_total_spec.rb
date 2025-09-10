require 'rails_helper'

RSpec.describe "Store total on products index", type: :request do
  it 'renders Total with the computed price using default rules' do
    # Seed products with base prices
    gr1 = Product.create!(code: 'GR1', name: 'Green Tea', base_price: 3.11)
    sr1 = Product.create!(code: 'SR1', name: 'Strawberries', base_price: 5.00)
    cf1 = Product.create!(code: 'CF1', name: 'Coffee', base_price: 11.23)

    # Add items to current cart via controller helper emulation
    cart = Cart.create!(session_id: SecureRandom.uuid)
    allow_any_instance_of(ApplicationController).to receive(:current_cart).and_return(cart)

    CartItem.create!(cart: cart, product: gr1, quantity: 2) # BOGO => pay 1
    CartItem.create!(cart: cart, product: sr1, quantity: 3) # bulk => 3 * 4.50
    CartItem.create!(cart: cart, product: cf1, quantity: 1)

    get products_path
    expect(response).to have_http_status(:ok)

    # Expected: GR1 (pay 1 => 3.11) + SR1 (3*4.50 => 13.50) + CF1 (11.23) = 27.84
    expect(response.body).to include("Total: €27.84")
  end
end
