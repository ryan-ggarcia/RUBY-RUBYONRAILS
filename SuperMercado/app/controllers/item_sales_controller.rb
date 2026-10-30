# Mesmo padrão do CategoriesController (veja os comentários lá).
class ItemSalesController < ApplicationController
  before_action :set_item_sale, only: %i[show edit update destroy]

  # GET /item_sales
  def index
    @item_sales = ItemSale.all
  end

  # GET /item_sales/1
  def show
  end

  # GET /item_sales/new
  def new
    @item_sale = ItemSale.new
  end

  # POST /item_sales
  def create
    @item_sale = ItemSale.new(item_sale_params)
    if @item_sale.save
      redirect_to @item_sale, notice: "Item cadastrado"
    else
      render :new, status: :unprocessable_content
    end
  end

  # GET /item_sales/1/edit
  def edit
  end

  # PATCH /item_sales/1
  def update
    if @item_sale.update(item_sale_params)
      redirect_to @item_sale, notice: "Item atualizado"
    else
      render :edit, status: :unprocessable_content
    end
  end

  # DELETE /item_sales/1
  def destroy
    @item_sale.destroy
    redirect_to item_sales_path, notice: "Item removido.", status: :see_other
  end

  private

  def set_item_sale
    @item_sale = ItemSale.find(params[:id])
  end

  def item_sale_params
    params.require(:item_sale).permit(:sale_id, :product_id, :quantity, :unit_price)
  end
end
