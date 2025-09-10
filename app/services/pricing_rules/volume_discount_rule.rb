module PricingRules
  class VolumeDiscountRule < BaseRule
    def initialize(product_code:, threshold:, factor:)
      @product_code = product_code
      @threshold = threshold
      @factor = BigDecimal(factor.to_s)
    end

    def apply(cart_items)
      items = cart_items.select { |i| i.product.code == @product_code }
      return BigDecimal("0") if items.empty?

      qty = items.sum(&:quantity)
      return BigDecimal("0") if qty < @threshold

      unit = unit_price(@product_code)
      discounted_unit = unit * @factor
      discount_per_item = unit - discounted_unit
      -discount_per_item * qty
    end
  end
end
