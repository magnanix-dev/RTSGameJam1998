extends Node

signal grid_changed(location)

var size_x = 0
var size_y = 0
var tiles = []

var void_tiles = [34, 12]

func initialize(_size_x, _size_y, tile = 1):
	size_x = _size_x
	size_y = _size_y
	for x in size_x:
		tiles.append([])
		for y in size_y:
			tiles[x].append(tile)

func in_grid(x, y):
	return (x >= 0 and x <= size_x-1 and y >= 0 and y <= size_y-1)

func is_void(id):
	return void_tiles.has(id)

func set_tile(x, y, tile):
	tiles[x][y] = tile
	emit_signal("grid_changed", Vector3(x, 0, y))
