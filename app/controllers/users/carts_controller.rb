class Users::CartsController < Users::ApplicationController
  def show
    @cart_items = current_cart.cart_items.includes(food: :cover_image_attachment).default_order
  end
end
