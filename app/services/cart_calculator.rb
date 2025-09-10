# Calculates a cart total with optional pricing rules.
# - Uses BigDecimal for money-safe math
# - Applies rules as discount amounts (negative numbers), keeping logic pluggable
#
# Example:
#   total = CartCalculator.new.calculate(current_cart)
#   total_with_rules = CartCalculator.new(pricing_rules: [PricingRules::BuyOneGetOneFreeRule.new(product_code: 'GR1')]).calculate(current_cart)

require "bigdecimal"
require "bigdecimal/util"

class CartCalculator
  def initialize(pricing_rules: nil)
    @pricing_rules = pricing_rules || default_pricing_rules
  end

  # Returns BigDecimal total rounded to 2 decimals
  def calculate(cart)
    raise ArgumentError, "cart is required" unless cart

    items = cart.cart_items.includes(:product).to_a

    # Subtotal: sum of unit price * quantity
    subtotal = items.inject(BigDecimal("0")) do |sum, item|
      sum + (item.product.base_price * item.quantity)
    end

    # Discounts: each rule returns a discount amount (negative for a discount, 0 otherwise)
    discount_total = @pricing_rules.inject(BigDecimal("0")) do |acc, rule|
      acc + BigDecimal(rule.apply(items).to_s)
    end

    # Final total (never below zero; adjust if your business allows negatives/credits)
    total = subtotal + discount_total
    [ total, BigDecimal("0") ].max.round(2)
  end

  # Optional: expose a simple line-item breakdown for UI or debugging
  def line_items(cart)
    cart.cart_items.includes(:product).map do |item|
      unit = item.product.base_price
      {
        product: item.product,
        quantity: item.quantity,
        unit_price: unit,
        line_total: (unit * item.quantity).round(2)
      }
    end
  end

  private

  def default_pricing_rules
    [
      PricingRules::BuyOneGetOneFreeRule.new(product_code: "GR1"),
      PricingRules::BulkDiscountRule.new(product_code: "SR1", threshold: 3, discounted_price: 4.50),
      PricingRules::VolumeDiscountRule.new(product_code: "CF1", threshold: 3, factor: BigDecimal("2")/3)
    ]
  end
end
