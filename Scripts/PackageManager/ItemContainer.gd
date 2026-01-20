# 容器类
extends Node

class_name ItemContainer

# 物品列表
var item_list : Array[Item] = []

# 容器可添加的物品标签
@export var addable_tags : Array[Tag] = []

# 容器大小
@export var size : int = 0		

# 容器描述
@export var description : String = ""

# 容器名称
@export var container_name : String = ""

signal item_changed(is_add : bool, index: int, item: Item)
signal size_changed(new_size : int)

# 容器初始化函数
func initialize(_size : int = 0, _container_name : String = "", _description : String = "", _addable_tags : Array[Tag] = [], _item_list : Array[Item] = []):
	self.container_name = _container_name
	self.description = _description
	self.addable_tags = _addable_tags
	self.item_list = _item_list
	set_item_list_size(_size)

# 设置容器大小
func set_item_list_size(new_size : int) -> bool:
	size = new_size
	if not item_list.resize(size):
		push_error("ItemContainer: set_item_list_size: 容器大小设置失败")
		return false
	return true

# ---------------
# 物品能否加入和移除容器相关code注释
# 200 - 成功添加/移除物品
# 400 - 物品标签不在容器可添加的标签列表中
# 401 - 物品添加的位置处已存在物品
# 402 - 物品堆叠数量超过最大堆叠数量
# 403 - 容器设置为check_tag为true，但是容器没有设置可添加的标签列表
# 404 - 物品内没有设置标签
# 405 - 物品所在位置已存在物品，但是物品id不同
# 406 - 指定的位置索引超出容器大小
# 407 - 物品的删除数量大于当前背包内的物品堆叠数量
# 408 - 指定的删除的index处的物品不存在

const CAN_ADD_ITEM_SUCCESS = 200
const CAN_ADD_ITEM_TAG_CONTAIN_ERROR = 400
const CAN_ADD_ITEM_INDEX_ERROR = 401
const CAN_ADD_ITEM_STACK_ERROR = 402
const CAN_ADD_ITEM_TAG_LIST_ERROR = 403
const CAN_ADD_ITEM_TAG_NULL_ERROR = 404
const CAN_ADD_ITEM_ID_CONFLICT_ERROR = 405
const CAN_ADD_ITEM_INDEX_OUT_OF_RANGE_ERROR = 406
const CAN_REMOVE_ITEM_SUCCESS = 200
const CAN_REMOVE_ITEM_NUM_ERROR = 407
const CAN_REMOVE_ITEM_INDEX_NULL_ERROR = 408

# ---------------

# 查看是否能够添加指定物品
func can_add_item(item : Item , index : int = -1, check_tag : bool = false) -> int:
	# 首先检查物品的标签，是否在容器可添加的标签列表中
	if check_tag:
		if item.data.tags.size() > 0:
			if addable_tags.size() > 0:
				for tag in item.data.tags:
					if tag in addable_tags:
						break
			else:
				return CAN_ADD_ITEM_TAG_LIST_ERROR
			push_error("ItemContainer: can_add_item: 物品", item, "标签不在容器可添加的标签列表中")
			return CAN_ADD_ITEM_TAG_CONTAIN_ERROR
		else:
			push_error("ItemContainer: can_add_item: 物品", item, "没有标签")
			return CAN_ADD_ITEM_TAG_LIST_ERROR
	# 先查是否有指定物品的摆放位置
	if index == -1 :
		index = item_list.find(null)
		if index == -1:
			index = item_list.find(item)
			if index == -1:
				push_error("ItemContainer: can_add_item: 容器", self, "没有空位置可以添加物品")
				return CAN_ADD_ITEM_INDEX_ERROR
	if index >= size:
		push_error("ItemContainer: can_add_item: 索引", index, "超出容器大小")
		return CAN_ADD_ITEM_INDEX_OUT_OF_RANGE_ERROR
	# 然后检查物品所在位置是否已经存在了别的物品
	if item_list[index] != null:
		var existing_item = item_list[index]
		if existing_item.data.id == item.data.id:
			# 如果是相同的id，那么我们查看是否有超出堆叠要求
			if existing_item.stack_count + item.stack_count > existing_item.data.max_stack:
				push_error("ItemContainer: can_add_item: 物品", item, "堆叠数量超过最大堆叠数量")
				return CAN_ADD_ITEM_STACK_ERROR
			else: 
				return CAN_ADD_ITEM_SUCCESS
		else:
			push_error("ItemContainer: can_add_item: 物品", item, "所在位置已存在物品，但是物品id不同")
			return CAN_ADD_ITEM_ID_CONFLICT_ERROR
	# 如果物品所在位置为空，那么我们可以直接添加
	else:
		return CAN_ADD_ITEM_SUCCESS

# 查看是否能够移除指定位置上的指定格数的物品
func can_remove_item(index : int = -1, num : int = 1) -> int :
	# 先检查index是否合法
	if index >= size or index == -1 :
		push_error("ItemContainer: can_remove_item: 索引", index, "超出容器大小")
		return CAN_ADD_ITEM_INDEX_OUT_OF_RANGE_ERROR
	# 检查指定的位置上是否有物品
	if item_list[index] == null :
		push_error("ItemContainer: can_remove_item: 索引", index, "处的物品不存在")
		return CAN_REMOVE_ITEM_INDEX_NULL_ERROR
	else :
		# 检查是否有足够的物品可以移除
		if item_list[index].stack_count < num:
			push_error("ItemContainer: can_remove_item: 索引", index, "处的物品堆叠数量不足，当前只有", item_list[index].stack_count, "个，需要移除", num, "个")
			return CAN_REMOVE_ITEM_NUM_ERROR
		else:
			return CAN_ADD_ITEM_SUCCESS

# 添加物品到容器
func add_item(item : Item, index : int = -1, check_tag : bool = false) -> int:
	# 先检查是否能够添加物品
	var can_add = can_add_item(item, index, check_tag)
	if can_add != CAN_ADD_ITEM_SUCCESS:
		push_error("ItemContainer: add_item: 物品", item, "不能添加到容器，错误码：", can_add)
		return can_add
	if item_list[index] == null:
		item_list[index] = item
	else: 
		item_list[index].stack_count += item.stack_count
	return can_add

# 删除指定位置的物品
func remove_item_in_position(index : int = -1, num : int = 1) -> int:
	# 先检查是否能够移除物品
	var can_remove = can_remove_item(index, num)
	if can_remove != CAN_REMOVE_ITEM_SUCCESS:
		push_error("ItemContainer: remove_item: 索引", index, "处的物品不能移除，错误码：", can_remove)
		return can_remove
	# 如果物品堆叠数量大于移除数量，那么我们只减少堆叠数量
	if item_list[index].stack_count > num:
		item_list[index].stack_count -= num
	# 如果物品堆叠数量等于移除数量，那么我们直接移除物品
	else:
		item_list[index] = null
	return CAN_REMOVE_ITEM_SUCCESS
	