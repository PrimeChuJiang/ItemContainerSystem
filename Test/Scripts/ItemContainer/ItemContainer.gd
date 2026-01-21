extends ItemContainer

class_name ItemContainerTest

# Called when the node enters the scene tree for the first time.
func _ready():
	var _apple = Item.new(load("res://Test/Items/apple.tres"))
	item_list.append(_apple)

func _input(event):
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_SPACE:
				item_list[0].use_item(self, self);
