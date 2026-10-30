# Mesmo padrão do CategoriesController (veja os comentários lá).
class ProductsController < ApplicationController
  before_action :set_product, only: %i[show edit update destroy]

  # GET /products
  def index
    @products = Product.all
  end

  # GET /products/1
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # POST /products
  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to @product, notice: "Produto cadastrado"
    else
      render :new, status: :unprocessable_content
    end
  end

  # GET /products/1/edit
  def edit
  end

  # PATCH /products/1
  def update
    if @product.update(product_params)
      redirect_to @product, notice: "Produto atualizado"
    else
      render :edit, status: :unprocessable_content
    end
  end

  # DELETE /products/1
  def destroy
    if @product.destroy
      redirect_to products_path, notice: "Produto removido.", status: :see_other
    else
      redirect_to products_path, alert: @product.errors.full_messages.to_sentence, status: :see_other
    end
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :price, :inventory, :barcode, :category_id)
  end
end
