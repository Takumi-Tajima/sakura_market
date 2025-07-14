class Users::OrdersController < Users::ApplicationController
  before_action :require_cart_items, only: %i[new create]
  before_action :set_cart_items, only: %i[new create]

  def new
    @order = current_user.orders.build
  end

  def create
    @order = current_user.orders.build(order_params)

    if @order.save_with_order_items_and_delete_cart(current_cart)
      redirect_to foods_path, notice: t('controllers.orders.created')
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def require_cart_items
    if current_cart.cart_items.empty?
      redirect_to users_cart_path, alert: t('cart.empty')
    end
  end

  def set_cart_items
    @cart_items = current_cart.cart_items.includes(:food).default_order
  end

  def order_params
    params.expect(order: %i[delivery_on delivery_time_slot])
  end
end
