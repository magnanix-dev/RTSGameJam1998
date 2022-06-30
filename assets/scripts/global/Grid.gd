extends Node

signal grid_changed(location)

var size_x = 0
var size_y = 0
var tiles = []

var void_tiles = []
var walkable_tiles = []

func _ready():
	for t in Tiles.tiles:
		if t.is_void: void_tiles.append(t.id)
		if t.is_walkable: walkable_tiles.append(t.id)

func initialize(_size_x, _size_y, tile = null):
	size_x = _size_x
	size_y = _size_y
	for x in size_x:
		tiles.append([])
		for y in size_y:
			var _tile = {"tile": tile.duplicate(), "building": null}
			tiles[x].append(_tile)

func in_grid(x, y):
	return (x >= 0 and x <= size_x-1 and y >= 0 and y <= size_y-1)

func is_void(x, y):
	var tile = get_tile(x, y)
	return void_tiles.has(tile.id)
	
func is_walkable(x, y):
	var cell = get_cell(x, y)
	return walkable_tiles.has(cell.tile.id) and (cell.building == null or cell.building.is_walkable)

func set_tile(x, y, tile, building = null):
	var _tile = {"tile": tile.duplicate(), "building": building}
	tiles[x][y] = _tile
	emit_signal("grid_changed", [Vector3(x, 0, y)])

func set_region(x, y, size_x, size_y, tile, building = null):
	var changes = []
	var start_x = x-floor(size_x/2)
	var start_y = y-floor(size_y/2)
	for _x in range(start_x, start_x+size_x, 1):
		for _y in range(start_y, start_y+size_y, 1):
			var _tile = {"tile": tile.duplicate(), "building": building}
			tiles[_x][_y] = _tile
			changes.append(Vector3(_x, 0, _y))
	emit_signal("grid_changed", changes)

func update_cell(x, y, tile = false, building = false):
	var cell = get_cell(x, y)
	if tile: cell.tile = tile
	if building: cell.building = building
	set_tile(x, y, cell.tile, cell.building)

func get_cell(x, y):
	return tiles[x][y]

func get_tile(x, y):
	return tiles[x][y].tile
	
func get_building(x, y):
	return tiles[x][y].building

func to_world(x, y):
	return Vector3(x, 0, y)

func convert_tile(x, y, conversion):
	var tile = Grid.get_tile(x, y)
	var building = Grid.get_building(x, y)
	if building != null:
		building.damage(conversion)
	else:
		tile.conversion -= conversion
		if tile.conversion <= 0:
			if Tasks.in_queue("excavate", Vector2(x, y)):
				var task = Tasks.get_queue_item("excavate", Vector2(x, y))
				if task != null:
					if task.reference: task.reference.owner.release_plan(task.reference)
					if task.transition: update_cell(x, y, task.transition)
					Tasks.remove_queue_item("excavate", Vector2(x, y))
			if Tasks.in_queue("claim", Vector2(x, y)):
				var task = Tasks.get_queue_item("claim", Vector2(x, y))
				if task != null:
					if task.transition: update_cell(x, y, task.transition)
					Tasks.remove_queue_item("claim", Vector2(x, y))
			if Tasks.in_queue("reinforce", Vector2(x, y)):
				var task = Tasks.get_queue_item("reinforce", Vector2(x, y))
				if task != null:
					if task.transition: update_cell(x, y, task.transition)
					Tasks.remove_queue_item("reinforce", Vector2(x, y))
