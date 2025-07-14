class Admins::OrdersController < Admins::ApplicationController
  before_action :set_order, only: %i[show]

  def index
    @orders = Order.includes(:user).default_order
  end

  def show
  end

  private

  def set_order
    @order = Order.find(params.expect(:id))
  end
end
