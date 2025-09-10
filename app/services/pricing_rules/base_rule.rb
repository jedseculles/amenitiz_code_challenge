require 'bigdecimal'

module PricingRules
  class BaseRule
    # items: Array<CartItem>, return BigDecimal discount (negative for discount, 0 otherwise)
    def apply(items)
      BigDecimal('0')
    end

    protected

    # Centralized price lookup to avoid duplicate rules
    def unit_price(code)
      Product.find_by!(code: code).base_price
    end
  end
end
