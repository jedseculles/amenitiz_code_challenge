require 'rails_helper'

RSpec.describe CartCalculator do
  # Helper to build a cart with items quickly
  def build_cart(items)
    cart = Cart.create!(session_id: SecureRandom.uuid)
    items.each do |attrs|
      product = Product.create!(code: attrs[:code], name: attrs[:name], base_price: attrs[:price])
      CartItem.create!(cart: cart, product: product, quantity: attrs[:qty])
    end
    cart
  end

  describe '#calculate' do
    it 'computes subtotal with no pricing rules' do
      # 2x GR1 at 3.11 + 1x SR1 at 5.00 = 11.22
      cart = build_cart([
        { code: 'GR1', name: 'Green Tea', price: 3.11, qty: 2 },
        { code: 'SR1', name: 'Strawberries', price: 5.00, qty: 1 }
      ])

      # Explicitly pass no rules, since CartCalculator has default rules configured
      total = described_class.new(pricing_rules: []).calculate(cart)
      expect(total).to eq(BigDecimal('11.22'))
    end

    it 'applies BuyOneGetOneFreeRule dynamically (price from Product)' do
      # 3x GR1 with BOGO => pay for 2 at current Product base_price
      cart = build_cart([
        { code: 'GR1', name: 'Green Tea', price: 3.11, qty: 3 }
      ])

      rules = [PricingRules::BuyOneGetOneFreeRule.new(product_code: 'GR1')]
      total = described_class.new(pricing_rules: rules).calculate(cart)

      # Subtotal = 3 * 3.11 = 9.33
      # BOGO discount = 1 * 3.11 => total = 6.22
      expect(total).to eq(BigDecimal('6.22'))
    end

    it 'applies BulkDiscountRule when threshold met' do
      # 3x SR1, threshold 3, discounted price 4.50 each
      cart = build_cart([
        { code: 'SR1', name: 'Strawberries', price: 5.00, qty: 3 }
      ])

      rules = [PricingRules::BulkDiscountRule.new(product_code: 'SR1', threshold: 3, discounted_price: 4.50)]
      total = described_class.new(pricing_rules: rules).calculate(cart)

      # Normal subtotal: 3 * 5.00 = 15.00
      # Discount: (5.00 - 4.50) * 3 = 1.50 => total = 13.50
      expect(total).to eq(BigDecimal('13.50'))
    end

    it 'applies VolumeDiscountRule when threshold met' do
      # 3x CF1, factor 2/3 of unit price (e.g., 11.23 * 2/3 each)
      cart = build_cart([
        { code: 'CF1', name: 'Coffee', price: 11.23, qty: 3 }
      ])

      rules = [PricingRules::VolumeDiscountRule.new(product_code: 'CF1', threshold: 3, factor: BigDecimal('2')/3)]
      total = described_class.new(pricing_rules: rules).calculate(cart)

      # Subtotal: 33.69
      # Discount per item: 11.23 - 11.23*(2/3) = 11.23/3 => total discount = 3 * 11.23/3 = 11.23
      # Total = 33.69 - 11.23 = 22.46
      expect(total).to eq(BigDecimal('22.46'))
    end

    it 'handles empty rules array' do
      cart = build_cart([{ code: 'GR1', name: 'Green Tea', price: 3.11, qty: 1 }])
      total = described_class.new(pricing_rules: []).calculate(cart)
      expect(total).to eq(BigDecimal('3.11'))
    end

    it 'raises on nil cart' do
      expect { described_class.new.calculate(nil) }.to raise_error(ArgumentError)
    end
  end
end
