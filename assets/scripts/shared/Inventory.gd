extends Resource
class_name Inventory

signal items_changed

var _items = [] setget set_items, get_items

func set_items(items):
	_items = items
	emit_signal("items_changed", _items)

func get_items():
	return _items

func get_item(index):
	return _items[index]

func add_item(item, quantity):
	if quantity <= 0:
		return
	
	if not Items.exists(item):
		return

	var remaining = quantity
	var stacksize = item.stack_size if item.stackable else 1
	
	if item.stackable:
		for i in range(_items.size()):
			if remaining == 0:
				break
			var _item = _items[i]
			if _item.item != item:
				continue
			if _item.quantity < stacksize:
				var _quantity = _item.quantity
				_item.quantity = min(_quantity + remaining, stacksize)
				remaining -= _item.quantity - _quantity
	
	while remaining > 0:
		var _new = {
			"item": item,
			"quantity": min(remaining, stacksize)
		}
		_items.append(_new)
		remaining -= _new.quantity
	
	emit_signal("items_changed")

func remove_item(item, quantity):
	if quantity <= 0:
		return
	
	if not Items.exists(item):
		return
	
	var remaining = quantity
	var stacksize = item.stack_size if item.stackable else 1
	
	for i in range(_items.size()):
		if remaining == 0:
			break
		var _item = _items[i]
		if _item.item != item:
			continue
		if _item.quantity >= remaining:
			var reduce = min(remaining, _item.quantity)
			remaining -= reduce
			_item.quantity -= reduce
			if _item.quantity <= 0: _items.erase(i)
	
	emit_signal("items_changed")

func transfer_item(item, quantity, target):
	if has_item(item, quantity):
		remove_item(item, quantity)
		target.add_item(item, quantity)
		
		emit_signal("items_changed")
		return true
	return false

func transfer_max(item, target):
	for i in range(_items.size()):
		var _item = _items[i]
		if _item.item == item:
			target.add_item(_item.item, _item.quantity)
			_items.erase(i)
	
	emit_signal("items_changed")

func transfer_all(target):
	for i in range(_items.size()):
		var _item = _items[i]
		target.add_item(_item.item, _item.quantity)
		_items.erase(i)
	
	emit_signal("items_changed")

func convert_cost(string):
	var costs = []
	var items = string.split(",")
	for i in items:
		i = i.trim()
		var item = i.split(":")
		var _new = {
			"item": Items.get_item(str(item[1])),
			"quantity": int(item[0])
		}
		costs.append(_new)
	return costs

func has_item(item, quantity = 1):
	var amount = 0
	for i in range(_items.size()):
		var _item = _items[i]
		if _item.item == item:
			amount += _item.quantity
	if amount > quantity:
		return true
	return false
