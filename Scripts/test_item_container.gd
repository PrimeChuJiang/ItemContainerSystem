extends ItemContainer

class_name ItemContainerTest

# Called when the node enters the scene tree for the first time.
func _ready():
	change_size(size)

func _input(event):
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_A:
				var item_a = ItemContainerSystem.get_item_data_by_id(0)
				add_item_by_itemdata(item_a)
			if event.keycode == KEY_B:
				var item_b = ItemContainerSystem.get_item_data_by_id(1)
				add_item_by_itemdata(item_b)
			if event.keycode == KEY_Q:
				remove_item_in_position(0)
			if event.keycode == KEY_W:
				get_item_in_position(0).use_item(self, self)
		var item_in_pos_0 = get_item_in_position(0)
		if item_in_pos_0 != null:
			print("Position 0 has item:", item_in_pos_0)
		else:
			print("Position 0 is empty")
