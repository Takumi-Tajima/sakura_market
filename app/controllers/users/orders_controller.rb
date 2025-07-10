class Users::OrdersController < Users::ApplicationController
  before_action :require_cart_items, only: %i[new]

  def new
    @order = current_user.orders.build
    @cart_items = current_cart.cart_items.includes(:food).default_order
  end

  def create
    @order = current_user.orders.build

    if @order.save_with_cart_items(current_cart)
      redirect_to foods_path, notice: '注文しました'
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  # def order_params
  #   {}
  # end

  def require_cart_items
    if current_cart.cart_items.empty?
      redirect_to users_cart_path, alert: t('cart.empty')
    end
  end
end
