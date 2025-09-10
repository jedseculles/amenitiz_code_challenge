require 'rails_helper'

RSpec.describe CartCalculator do
  # Utility to build a cart with an array of item hashes
  def build_cart(items)
    cart = Cart.create!(session_id: SecureRandom.uuid)
    items.each do |attrs|
      product = Product.create!(code: attrs[:code], name: attrs[:name], base_price: attrs[:price])
      CartItem.create!(cart: cart, product: product, quantity: attrs[:qty])
    end
    cart
  end

  # According to the challenge plan:
  # - GR1: Green Tea €3.11 (BOGO)
  # - SR1: Strawberries €5.00 (3+ => €4.50 each)
  # - CF1: Coffee €11.23 (3+ => 2/3 price per item)

  let(:gr1_price) { 3.11 }
  let(:sr1_price) { 5.00 }
  let(:cf1_price) { 11.23 }

  it 'Scenario 1: GR1, SR1, GR1, GR1, CF1 = €22.45' do
    cart = build_cart([
      { code: 'GR1', name: 'Green Tea', price: gr1_price, qty: 3 }, # three GR1 total
      { code: 'SR1', name: 'Strawberries', price: sr1_price, qty: 1 },
      { code: 'CF1', name: 'Coffee', price: cf1_price, qty: 1 }
    ])

    total = described_class.new.calculate(cart)
    expect(total).to eq(BigDecimal('22.45'))
  end

  it 'Scenario 2: GR1, GR1 = €3.11 (BOGO)' do
    cart = build_cart([
      { code: 'GR1', name: 'Green Tea', price: gr1_price, qty: 2 }
    ])

    total = described_class.new.calculate(cart)
    expect(total).to eq(BigDecimal('3.11'))
  end

  it 'Scenario 3: SR1, SR1, GR1, SR1 = €16.61' do
    cart = build_cart([
      { code: 'SR1', name: 'Strawberries', price: sr1_price, qty: 3 },
      { code: 'GR1', name: 'Green Tea', price: gr1_price, qty: 1 }
    ])

    total = described_class.new.calculate(cart)
    expect(total).to eq(BigDecimal('16.61'))
  end

  it 'Scenario 4: GR1, CF1, SR1, CF1, CF1 = €30.57' do
    cart = build_cart([
      { code: 'GR1', name: 'Green Tea', price: gr1_price, qty: 1 },
      { code: 'SR1', name: 'Strawberries', price: sr1_price, qty: 1 },
      { code: 'CF1', name: 'Coffee', price: cf1_price, qty: 3 }
    ])

    total = described_class.new.calculate(cart)
    expect(total).to eq(BigDecimal('30.57'))
  end
end
