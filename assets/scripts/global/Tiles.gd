extends Node

var tiles = []

func _ready():
	var directory = Directory.new()
	directory.open("res://assets/resources/tiles")
	directory.list_dir_begin()
	
	var filename = directory.get_next()
	while(filename):
		if not directory.current_is_dir():
			tiles.append(load("res://assets/resources/tiles/%s" % filename))
		filename = directory.get_next()

func get(name):
	for i in tiles:
		if i.name == name:
			return i
	return null

func exists(tile):
	for i in tiles:
		if i == tile:
			return true
	return false
