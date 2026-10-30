# Mesmo padrão do CategoriesController (veja os comentários lá).
class CheckoutsController < ApplicationController
  before_action :set_checkout, only: %i[show edit update destroy]

  # GET /checkouts
  def index
    @checkouts = Checkout.all
  end

  # GET /checkouts/1
  def show
  end

  # GET /checkouts/new
  def new
    @checkout = Checkout.new
  end

  # POST /checkouts
  def create
    @checkout = Checkout.new(checkout_params)
    if @checkout.save
      redirect_to @checkout, notice: "Caixa cadastrado"
    else
      render :new, status: :unprocessable_content
    end
  end

  # GET /checkouts/1/edit
  def edit
  end

  # PATCH /checkouts/1
  def update
    if @checkout.update(checkout_params)
      redirect_to @checkout, notice: "Caixa atualizado"
    else
      render :edit, status: :unprocessable_content
    end
  end

  # DELETE /checkouts/1
  def destroy
    if @checkout.destroy
      redirect_to checkouts_path, notice: "Caixa removido.", status: :see_other
    else
      redirect_to checkouts_path, alert: @checkout.errors.full_messages.to_sentence, status: :see_other
    end
  end

  private

  def set_checkout
    @checkout = Checkout.find(params[:id])
  end

  def checkout_params
    params.require(:checkout).permit(:name, :open)
  end
end
