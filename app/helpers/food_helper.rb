module FoodHelper
  def food_cover_tag(food, variant)
    image_tag food.cover_image.attached? ? food.cover_image.variant(variant) : 'no_image.jpg', class: 'img-fluid rounded'
  end
end
