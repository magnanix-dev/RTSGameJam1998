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
	var cell = tiles[x][y]
	if not is_instance_valid(cell.building):
		tiles[x][y].building = null
		cell.building = null
	return cell

func get_tile(x, y):
	return tiles[x][y].tile
	
func get_building(x, y):
	return tiles[x][y].building

func to_world(x, y, elevation = 0):
	return Vector3(x, elevation, y)

func convert_tile(x, y, conversion):
	var tile = Grid.get_tile(x, y)
	var building = Grid.get_building(x, y)
	if building != null:
		building.damage(conversion)
	else:
		tile.conversion -= conversion
		if tile.conversion <= 0:
			var vector = Vector2(x, y)
			if Tasks.in_queue("excavate", vector):
				var task = Tasks.get_queue_item("excavate", vector)
				if task != null:
					if task.reference: task.reference.owner.release_plan(task.reference)
					if task.transition: update_cell(x, y, task.transition)
					if int(x) % 5 == 0 or int(y) % 5 == 0:
						var dungeon_ground = Tiles.get("dungeon:ground")
						var neighbours = [vector + Vector2.UP, vector + Vector2.RIGHT, vector + Vector2.DOWN, vector + Vector2.LEFT]
						for n in neighbours:
							if Grid.in_grid(n.x, n.y):
								var n_tile = Grid.get_tile(n.x, n.y) 
								var n_building = Grid.get_building(n.x, n.y) # Convert this later, add a 3rd toplevel to Grid Dictionary: Lighting
								if n_building != null and n_tile.id == dungeon_ground.id:
									n_building.queue_free()
									Grid.update_cell(n.x, n.y, false, null)
					Tasks.remove_queue_item("excavate", vector)
					Tasks.remove_queue_item("reinforce", vector)
					return
			if Tasks.in_queue("claim", vector):
				var task = Tasks.get_queue_item("claim", vector)
				if task != null:
					if task.transition: update_cell(x, y, task.transition)
					Tasks.remove_queue_item("claim", vector)
					return
			if Tasks.in_queue("reinforce", vector):
				var task = Tasks.get_queue_item("reinforce", vector)
				if task != null:
					var dungeon_ground = Tiles.get("dungeon:ground")
					var dungeon_torch = Buildings.get("dungeon:torch")
					if task.transition: update_cell(x, y, task.transition)
					if int(x) % 5 == 0 or int(y) % 5 == 0:
						var neighbours = [vector + Vector2.UP, vector + Vector2.RIGHT, vector + Vector2.DOWN, vector + Vector2.LEFT]
						var has_torch = false
						for n in neighbours:
							if Grid.in_grid(n.x, n.y) and not has_torch:
								var n_tile = Grid.get_tile(n.x, n.y) 
								var n_building = Grid.get_building(n.x, n.y) # Convert this later, add a 3rd toplevel to Grid Dictionary: Lighting
								if n_building == null and n_tile.id == dungeon_ground.id:
									var offset = vector + ((n - vector) * 0.5) + Vector2(0.5, 0.5)
									var dt = dungeon_torch.scene.instance()
									dt.transform.origin = Grid.to_world(offset.x, offset.y)
									Global._buildings.add_child(dt)
									Grid.update_cell(n.x, n.y, false, dt)
									has_torch = true
					Tasks.remove_queue_item("reinforce", vector)
					return
