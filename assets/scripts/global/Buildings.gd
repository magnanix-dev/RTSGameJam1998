extends Node

var buildings = []

func _ready():
	var directory = Directory.new()
	directory.open("res://assets/resources/buildings")
	directory.list_dir_begin()
	
	var filename = directory.get_next()
	while(filename):
		if not directory.current_is_dir():
			buildings.append(load("res://assets/resources/buildings/%s" % filename))
		filename = directory.get_next()

func get(name):
	for b in buildings:
		if b.name == name:
			return b
	return null

func exists(building):
	for b in buildings:
		if b == building:
			return true
	return false
