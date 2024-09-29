class_name FoodCounter extends TextureRect

@onready var count_label = $food_count_label

func UpdateCounter(amount):
	count_label.text = str(amount)
