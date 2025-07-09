module FoodHelper
  def food_cover_tag(food, variant)
    if food.cover_image.attached?
      image_tag food.cover_image.variant(variant), alt: food.name, class: 'img-fluid object-fit-cover'
    else
      content_tag :div, '画像なし', class: 'text-muted'
    end
  end
end
