# Mesmo padrão do CategoriesController (veja os comentários lá).
class SalesController < ApplicationController
  before_action :set_sale, only: %i[show edit update destroy]

  # GET /sales
  def index
    @sales = Sale.all
  end

  # GET /sales/1
  def show
  end

  # GET /sales/new
  def new
    @sale = Sale.new
  end

  # POST /sales
  def create
    @sale = Sale.new(sale_params)
    if @sale.save
      redirect_to @sale, notice: "Venda cadastrada"
    else
      render :new, status: :unprocessable_content
    end
  end

  # GET /sales/1/edit
  def edit
  end

  # PATCH /sales/1
  def update
    if @sale.update(sale_params)
      redirect_to @sale, notice: "Venda atualizada"
    else
      render :edit, status: :unprocessable_content
    end
  end

  # DELETE /sales/1
  def destroy
    @sale.destroy
    redirect_to sales_path, notice: "Venda removida.", status: :see_other
  end

  private

  def set_sale
    @sale = Sale.find(params[:id])
  end

  def sale_params
    params.require(:sale).permit(:checkout_id, :total, :status, :completed_at)
  end
end
