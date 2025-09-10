require 'rails_helper'

RSpec.describe "Products", type: :request do
  let!(:active_product) { Product.create!(code: 'SR1', name: 'Strawberries', base_price: 5.00, active: true) }
  let!(:inactive_product) { Product.create!(code: 'CF1', name: 'Coffee', base_price: 11.23, active: false) }

  describe "GET /products" do
    it "shows only active products for the storefront" do
      get products_path

      # Page should render successfully
      expect(response).to have_http_status(:ok)

      # Should contain active product name, but not the inactive one
      expect(response.body).to include(active_product.name)
      expect(response.body).not_to include(inactive_product.name)

      # Should include store-specific elements
      expect(response.body).to include("Store")
      expect(response.body).to include("Items in cart:")
    end
  end
end
