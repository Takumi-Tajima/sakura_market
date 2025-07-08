module FoodHelper
  def food_cover_tag(food, variant, css_class: nil)
    if food.cover_image.attached?
      default_class = variant == :medium ? 'img-fluid rounded-start h-100' : 'img-fluid rounded'
      image_tag food.cover_image.variant(variant), alt: food.name, class: css_class || default_class
    else
      default_class = variant == :medium ? 'bg-light d-flex align-items-center justify-content-center h-100 rounded-start' : 'bg-light text-center py-5 rounded'
      content_tag :div, class: css_class || default_class do
        content_tag :span, '画像なし', class: 'text-muted'
      end
    end
  end
end
