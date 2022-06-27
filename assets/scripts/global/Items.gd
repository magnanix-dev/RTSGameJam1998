extends Node

var items = []

func _ready():
	var directory = Directory.new()
	directory.open("res://assets/resources/items")
	directory.list_dir_begin()
	
	var filename = directory.get_next()
	while(filename):
		if not directory.current_is_dir():
			items.append(load("res://assets/resources/items/%s" % filename))
		filename = directory.get_next()

func get_item(name):
	for i in items:
		if i.name == name:
			return i
	return null

func exists(item):
	for i in items:
		if i == item:
			return true
	return false
