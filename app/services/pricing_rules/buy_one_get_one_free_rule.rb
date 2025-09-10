module PricingRules
  class BuyOneGetOneFreeRule < BaseRule
    def initialize(product_code:)
      @product_code = product_code
    end

    def apply(cart_items)
      items = cart_items.select { |i| i.product.code == @product_code }
      return BigDecimal("0") if items.empty?

      qty = items.sum(&:quantity)
      free_qty = qty / 2
      discount = unit_price(@product_code) * free_qty

      -discount
    end
  end
end
