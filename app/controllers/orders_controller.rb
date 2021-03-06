class OrdersController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def index
    @orders = @orders.paginate page: params[:page], per_page: Settings.per_page
  end

  def show
    @order_items = @order.order_items.includes :product
  end

  def checkout
    @order = Order.new
  end

  def create
    @order = Order.new order_params
    @order.user_id = current_user.id
    if @order.save
      session[:cart].each do |c|
        @item = @order.order_items.create!(product_id: c["product_id"],
          quantity: c["quantity"], price: c["price"])
        @item.product.update_quantity @item.quantity
      end
      set_cart
    else
      render :checkout
    end
  end

  def destroy
    if @order.destroy
      flash[:success] = t ".orders_dell"
    else
      flash[:danger] = t ".not_orders_dell"
    end
    redirect_to orders_path
  end

  private
  def order_params
    params.require(:order).permit :receiver_name, :receiver_address,
      :receiver_phone, :total_price, :address
  end

  def set_cart
    session[:cart] = []
    flash[:success] = t ".checkout_sucsess"
    redirect_to orders_path
  end
end
