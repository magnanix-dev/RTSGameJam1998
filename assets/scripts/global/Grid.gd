extends Node

signal grid_changed(location)

var size_x = 0
var size_y = 0
var tiles = []

var void_tiles = [0, 34, 12]

func initialize(_size_x, _size_y, tile = {"id": 1, "building": null}):
	size_x = _size_x
	size_y = _size_y
	for x in size_x:
		tiles.append([])
		for y in size_y:
			tiles[x].append(tile)

func in_grid(x, y):
	return (x >= 0 and x <= size_x-1 and y >= 0 and y <= size_y-1)

func is_void(tile):
	return void_tiles.has(tile.id)

func set_tile(x, y, tile):
	tiles[x][y] = tile
	emit_signal("grid_changed", Vector3(x, 0, y))

func set_region(x, y, size, tile):
	var start_x = x-floor(size.x/2)
	var start_y = y-floor(size.y/2)
	for _x in range(start_x, start_x+size.x, 1):
		for _y in range(start_y, start_y+size.y, 1):
			set_tile(_x, _y, tile)

func get_tile(x, y):
	return tiles[x][y]

func to_world(x, y):
	return Vector3(x, 0, y)
