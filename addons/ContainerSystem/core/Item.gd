# 物品计算类，这个类用于对物品进行实时计算
extends RefCounted

class_name Item

# 物品信息配置的引用（只读，不修改配置）
var data: ItemData:
	set(value):
		if _data == null:
			_data = value
	get:
		return _data
var _data: ItemData = null

# 物品行为配置引用（只读，不修改配置）
var behaviours: Array[ItemBehaviourData]:
	set(value):
		if _behaviour == []:
			_behaviour = value
	get:
		return _behaviour
var _behaviour: Array[ItemBehaviourData] = []

# 运行时动态数据（只有运行时才会变化的属性）
var stack_count: int = 1  # 当前堆叠数量

# 构造函数：通过【配置类】快速创建【运行类】实例
func _init(_data_: ItemData, _stack_count: int = 1):
	self.data = _data_
	self.behaviours = _data_.behaviours
	self.stack_count = clamp(_stack_count, 1, _data_.max_stack)
	
# 使用物品调用函数
func use_item(character_from : Node, character_to : Node) -> void :
	_triger_behaviour("use_item", character_from, character_to)

# 触发behaviour内的函数
func _triger_behaviour(func_name : String, character_from : Node, character_to : Node) -> Variant :
	if behaviours.size() > 0:
		print_debug("触发物品行为：", func_name, "，物品：", self)
		for behaviour in behaviours:
			behaviour.use_item(self, character_from, character_to)
	else :
		push_error("Item: _triger_behaviour: 物品", self, "没有物品行为")
	return null

# 快捷获取静态数据的封装（语法糖，调用更简洁）
func get_id() -> int: return data.id
func get_name() -> String: return data.name
func get_icon() -> Texture2D: return data.icon
func get_max_stack() -> int: return data.max_stack
