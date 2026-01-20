extends ItemBehaviourData

class_name AppleBehaviour

# 使用函数，返回使用了多少个
func use_item(item : Item, character_from : Node, character_to : Node) -> Variant:
	print("AppleBehaviour: on_use", item.get_name(), character_from, character_to)
	return
