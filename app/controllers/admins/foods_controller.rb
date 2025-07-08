class Admins::FoodsController < Admins::ApplicationController
  before_action :set_food, only: %i[show edit update destroy]

  def index
    @foods = Food.default_order
  end

  def show
  end

  def new
    @food = Food.new
  end

  def edit
  end

  def create
    @food = Food.new(food_params)

    if @food.save
      redirect_to admins_food_path(@food), notice: t('controllers.created')
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @food.update(food_params)
      redirect_to admins_food_path(@food), notice: t('controllers.updated'), status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @food.destroy!
    redirect_to admins_foods_path, notice: t('controllers.destroyed'), status: :see_other
  end

  private

  def set_food
    @food = Food.find(params.expect(:id))
  end

  def food_params
    params.expect(food: %i[name description price published published])
  end
end
