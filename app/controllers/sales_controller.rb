class SalesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_sale, only: %i[ show edit update destroy ]
  before_action :check_role, only: %i[ index destroy edit update]

  # GET /sales or /sales.json
  def index
    @sales = Sale.all
  end

  # GET /sales/1 or /sales/1.json
  def show
  end

  # GET /sales/new
  def new
    @sale = Sale.new
  end

  # GET /sales/1/edit
  def edit
  end

  # POST /sales or /sales.json
  def create
    @sale = Sale.new(sale_params)

    respond_to do |format|
      if @sale.save
        format.html { redirect_to @sale, notice: "Sale was successfully created." }
        format.json { render :show, status: :created, location: @sale }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @sale.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sales/1 or /sales/1.json
  def update
    respond_to do |format|
      if @sale.update(sale_params)
        format.html { redirect_to @sale, notice: "Sale was successfully updated." }
        format.json { render :show, status: :ok, location: @sale }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @sale.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sales/1 or /sales/1.json
  def destroy
    for product_sale in @sale.product_sale
      product_sale.destroy
    end
    @sale.destroy
    respond_to do |format|
      format.html { redirect_to sales_url, notice: "Sale was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def finalizeSale
    @sale = Sale.find(params[:id])

    @sale.product_sale.each do |product_sale|
      Produto.update(product_sale.produto_id, :quantidade => product_sale.produto.quantidade - product_sale[:quantity].to_d)
    end
    @sale.update(:date_time => DateTime.current)
    redirect_to root_path, notice: "Sale was successfully finalized."
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sale
      @sale = Sale.where("id = ?", params[:id]).first
    end

    # Only allow a list of trusted parameters through.
    def sale_params
      params.require(:sale).permit(:totalValue, :date_time, :customer_id)
    end
end