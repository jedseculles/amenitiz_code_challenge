require 'rails_helper'

RSpec.describe 'PricingRules' do
  # Build cart items array with a single product code and quantity
  def build_items(code:, price:, quantity:)
    product = Product.create!(code: code, name: code, base_price: price)
    cart = Cart.create!(session_id: SecureRandom.uuid)
    [CartItem.create!(cart: cart, product: product, quantity: quantity)]
  end

  describe PricingRules::BuyOneGetOneFreeRule do
    it 'returns discount equal to floor(qty/2) * unit' do
      items = build_items(code: 'GR1', price: 3.11, quantity: 5) # 5 => 2 free
      rule = described_class.new(product_code: 'GR1')
      discount = rule.apply(items)
      expect(discount).to eq(BigDecimal('-6.22'))
    end
  end

  describe PricingRules::BulkDiscountRule do
    it 'returns 0 when below threshold' do
      items = build_items(code: 'SR1', price: 5.00, quantity: 2)
      rule = described_class.new(product_code: 'SR1', threshold: 3, discounted_price: 4.50)
      expect(rule.apply(items)).to eq(BigDecimal('0'))
    end

    it 'returns (unit - discounted) * qty as negative discount when reached' do
      items = build_items(code: 'SR1', price: 5.00, quantity: 4)
      rule = described_class.new(product_code: 'SR1', threshold: 3, discounted_price: 4.50)
      expect(rule.apply(items)).to eq(BigDecimal('-2.00')) # (5.00-4.50)*4 = 2.00 discount
    end
  end

  describe PricingRules::VolumeDiscountRule do
    it 'returns 0 when below threshold' do
      items = build_items(code: 'CF1', price: 11.23, quantity: 2)
      rule = described_class.new(product_code: 'CF1', threshold: 3, factor: BigDecimal('2')/3)
      expect(rule.apply(items)).to eq(BigDecimal('0'))
    end

    it 'returns (unit - unit*factor) * qty as negative discount' do
      items = build_items(code: 'CF1', price: 11.23, quantity: 3)
      rule = described_class.new(product_code: 'CF1', threshold: 3, factor: BigDecimal('2')/3)
      # Discount per item: 11.23 - 11.23*(2/3) = 11.23/3 => total discount: -11.23 (round to 2 decimals)
      expect(rule.apply(items).round(2)).to eq(-BigDecimal('11.23'))
    end
  end
end
