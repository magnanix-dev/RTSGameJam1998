extends Buildable
class_name Core

export (Array, Resource) var units = []

func toggle_ui():
	spawn_unit(0)
	pass

func spawn_unit(index):
	var unit = units[index] # Select the unit to spawn
	spawn_tiles.shuffle() # Select a random tile from the viable options
	var tile = spawn_tiles[0]
	
	var scene = unit.scene.instance()
	scene.spawn(Grid.to_world(tile.x, tile.y))
	Global._units.add_child(scene)
