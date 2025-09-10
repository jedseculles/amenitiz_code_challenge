class CartsController < ApplicationController
  # GET /cart
  def show
    @cart = current_cart
  end

  # POST /cart/add
  def add
    product = Product.find(params.require(:product_id))
    item = current_cart.cart_items.find_or_initialize_by(product: product)

    # If this is a new cart item, start at 1 (schema default is 1) and avoid double increment
    if item.new_record?
      item.quantity = 1
    else
      item.quantity = item.quantity.to_i + 1
    end
    item.save!

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to products_path, notice: "#{product.name} added to cart" }
    end
  end

  # DELETE /cart/remove/:product_id
  def remove
    product = Product.find(params.require(:product_id))
    item = current_cart.cart_items.find_by(product: product)

    if item.present?
      if item.quantity.to_i > 1
        item.update!(quantity: item.quantity - 1)
      else
        item.destroy!
      end
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to products_path, notice: "#{product.name} removed from cart" }
    end
  end

  # DELETE /cart/clear
  def clear
    current_cart.cart_items.destroy_all

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to products_path, notice: "Cart cleared" }
    end
  end
end
