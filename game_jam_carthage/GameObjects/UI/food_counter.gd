class_name FoodCounter extends TextureRect

@onready var count_label = $food_count_label

func UpdateCounter(amount: int):
	count_label.text = str(amount)
