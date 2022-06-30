extends Spatial
class_name Buildable

var location = null
var size = Vector2.ONE

export var is_walkable = false

export var spawnable = false setget spawnable
var spawn_tiles = []

func build(x, y, size_override = size):
	location = Vector2(x, y)
	size = size_override
	var ground = Tiles.get("dungeon:ground")
	Grid.set_region(x, y, size.x, size.y, ground, self) # Adjust this to be building specific later
	global_transform.origin = Grid.to_world(x, y)
	if spawnable:
		Grid.connect("grid_changed", self, "update_spawn_tiles")
		update_spawn_tiles()

func update_spawn_tiles():
	spawn_tiles = []
	var vector = Vector2.ZERO
	for _x in range(location.x-floor(size.x/2)-1, location.x+floor(size.x/2)+2, 1):
		vector = Vector2(_x, location.y-floor(size.y/2)-1)
		if Grid.in_grid(vector.x, vector.y) and Grid.is_walkable(vector.x, vector.y):
			spawn_tiles.append(vector)
		vector = Vector2(_x, location.y+floor(size.y/2)+1)
		if Grid.in_grid(vector.x, vector.y) and Grid.is_walkable(vector.x, vector.y):
			spawn_tiles.append(vector)
	for _y in range(location.y-floor(size.y/2)-1, location.y+floor(size.y/2)+2, 1):
		vector = Vector2(location.x-floor(size.x/2)-1, _y)
		if Grid.in_grid(vector.x, vector.y) and Grid.is_walkable(vector.x, vector.y):
			spawn_tiles.append(vector)
		vector = Vector2(location.x+floor(size.x/2)+1, _y)
		if Grid.in_grid(vector.x, vector.y) and Grid.is_walkable(vector.x, vector.y):
			spawn_tiles.append(vector)

func toggle_ui():
	return

func spawnable(val : bool):
	spawnable = val
