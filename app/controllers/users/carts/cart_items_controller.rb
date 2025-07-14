class Users::Carts::CartItemsController < Users::ApplicationController
  before_action :set_cart_item, only: %i[edit update destroy]
  before_action :set_food, only: %i[new]

  def new
    @cart_item = current_cart.cart_items.build(food: @food)
  end

  def create
    @cart_item = current_cart.cart_items.build(cart_item_params)

    if @cart_item.save
      redirect_to users_cart_path, notice: t('controllers.cart_items.created')
    else
      @food = @cart_item.food
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @cart_item.update(cart_item_params)
      redirect_to users_cart_path, notice: t('controllers.updated')
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @cart_item.destroy!
    redirect_to users_cart_path, notice: t('controllers.destroyed'), status: :see_other
  end

  private

  def set_cart_item
    @cart_item = current_cart.cart_items.find(params.expect(:id))
  end

  def set_food
    @food = Food.published.find(params.expect(:food_id))
  end

  def cart_item_params
    params.expect(cart_item: %i[food_id quantity])
  end
end
