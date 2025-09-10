class CartsController < ApplicationController
  # GET /cart
  def show
    @cart = current_cart
  end

  # POST /cart/add
  def add
    @product = Product.find(params.require(:product_id))
    @item = current_cart.cart_items.find_or_initialize_by(product: @product)

    # If this is a new cart item, start at 1 (schema default is 1) and avoid double increment
    if @item.new_record?
      @item.quantity = 1
    else
      @item.quantity = @item.quantity.to_i + 1
    end
    @item.save!

    # Prepare derived data for turbo views
    @cart_count = current_cart.cart_items.sum(:quantity)
    @cart_total = CartCalculator.new.calculate(current_cart)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to products_path, notice: "#{@product.name} added to cart" }
    end
  end

  # DELETE /cart/remove/:product_id
  def remove
    @product = Product.find(params.require(:product_id))
    item = current_cart.cart_items.find_by(product: @product)

    if item.present?
      if item.quantity.to_i > 1
        item.update!(quantity: item.quantity - 1)
      else
        item.destroy!
      end
    end

    # Reload the (possibly nil) item for the view
    @item = current_cart.cart_items.find_by(product: @product)
    @cart_count = current_cart.cart_items.sum(:quantity)
    @cart_total = CartCalculator.new.calculate(current_cart)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to products_path, notice: "#{@product.name} removed from cart" }
    end
  end

  # DELETE /cart/clear
  def clear
    current_cart.cart_items.destroy_all

    # Prepare data for turbo views without additional queries in the views
    @cart_count = 0
    @cart_total = BigDecimal("0")
    @all_product_ids = Product.active.pluck(:id)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to products_path, notice: "Cart cleared" }
    end
  end
end
