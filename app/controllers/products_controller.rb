class ProductsController < ApplicationController
  before_action :set_product, only: %i[ show edit update destroy ]

  # GET /products
  def index
    # Store-facing catalog should only show active products
    @products = Product.active.order(:name)

    # Compute the current cart total with pricing rules
    @cart_total = CartCalculator.new.calculate(current_cart)
  end

  # GET /products/1
  def show
  end

  # NOTE: Leaving all admin CRUD actions for faster adding/deleting of products in the store

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: "Product was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: "Product was successfully updated.", status: :see_other }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  def destroy
    @product.destroy!

    respond_to do |format|
      format.html { redirect_to products_path, notice: "Product was successfully destroyed.", status: :see_other }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions
    def set_product
      @product = Product.find(params[:id])
    end

    # Only allow a list of trusted parameters
    def product_params
      params.fetch(:product, {}).permit(:code, :name, :base_price, :active)
    end
end
