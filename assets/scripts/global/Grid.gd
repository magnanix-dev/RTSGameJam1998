extends Node

signal grid_changed(location)

var size_x = 0
var size_y = 0
var tiles = []

var void_tiles = [0, 34, 12, 11, 29]
var walkable_tiles = [34, 12, 11, 29]

func initialize(_size_x, _size_y, tile = null):
	size_x = _size_x
	size_y = _size_y
	for x in size_x:
		tiles.append([])
		for y in size_y:
			var _tile = tile.duplicate()
			tiles[x].append(_tile)

func in_grid(x, y):
	return (x >= 0 and x <= size_x-1 and y >= 0 and y <= size_y-1)

func is_void(tile):
	return void_tiles.has(tile.id)
	
func is_walkable(tile):
	return walkable_tiles.has(tile.id) and ("building" in tile and tile.building == null)

func set_tile(x, y, tile):
	var _tile = tile.duplicate()
	tiles[x][y] = _tile
	emit_signal("grid_changed", [Vector3(x, 0, y)])

func set_region(x, y, size_x, size_y, tile):
	var changes = []
	var start_x = x-floor(size_x/2)
	var start_y = y-floor(size_y/2)
	for _x in range(start_x, start_x+size_x, 1):
		for _y in range(start_y, start_y+size_y, 1):
			var _tile = tile.duplicate()
			tiles[_x][_y] = _tile
			changes.append(Vector3(_x, 0, _y))
	emit_signal("grid_changed", changes)

func get_tile(x, y):
	return tiles[x][y]

func to_world(x, y):
	return Vector3(x, 0, y)

func damage_tile(x, y, damage):
	var tile = Grid.get_tile(x, y)
	if tile.building != null:
		tile.building.take_damage(damage)
	else:
		print("Damage Tile: ", damage, " - (", x, ", ", y, ")")
		if "health" in tile:
			tile.health -= damage
			print(tile.health)
			if tile.health <= 0:
				if Tasks.in_queue("excavate", Vector2(x, y)):
					var task = Tasks.get_queue_item("excavate", Vector2(x, y))
					if task != null: task.reference.owner.release_plan(task.reference)
					Tasks.remove_queue_item("excavate", Vector2(x, y))
					if "transition" in tile:
						set_tile(x, y, tile.transition)
				if Tasks.in_queue("pave", Vector2(x, y)):
					Tasks.remove_queue_item("pave", Vector2(x, y))
					if "transition" in tile:
						set_tile(x, y, tile.transition)
