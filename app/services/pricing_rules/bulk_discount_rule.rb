module PricingRules
  class BulkDiscountRule < BaseRule
    def initialize(product_code:, threshold:, discounted_price:)
      @product_code = product_code
      @threshold = threshold
      @discounted_price = BigDecimal(discounted_price.to_s)
    end

    def apply(cart_items)
      items = cart_items.select { |i| i.product.code == @product_code }
      return BigDecimal('0') if items.empty?

      qty = items.sum(&:quantity)
      return BigDecimal('0') if qty < @threshold

      discount_per_item = unit_price(@product_code) - @discounted_price
      -discount_per_item * qty
    end
  end
end