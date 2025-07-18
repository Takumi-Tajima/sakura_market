class Users::ApplicationController < ApplicationController
  before_action :authenticate_user!

  helper_method :current_cart

  private

  def current_cart
    @current_cart ||= current_user.cart || current_user.create_cart!
  end
end
