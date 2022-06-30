extends Spatial

export var grid_size = Vector2.ZERO
export (Resource) var material

export (Resource) var core_building

onready var pivot = $Dynamic/Pivot
onready var label = $Label

onready var _static = $Static
onready var _dynamic = $Dynamic
onready var _buildings = $Buildings
onready var _units = $Units

var _chunks = {}

func _ready():
	Global.register_containers(_static, _dynamic, _buildings, _units)
	pivot.transform.origin = Vector3(floor(grid_size.x/2)+0.5, 0, floor(grid_size.y/2))
	Grid.initialize(grid_size.x, grid_size.y, {"id": 35, "building": null, "health": 10, "transition": {"id": 34, "building": null, "health": 3, "transition": {"id": 29, "building": null}}})
	var mid_x = floor(grid_size.x/2)
	var mid_y = floor(grid_size.y/2)
	Grid.set_region(mid_x, mid_y, 5, 5, {"id": 34, "building": null, "health": 3, "transition": {"id": 29, "building": null}})
	Grid.set_tile(mid_x+3, mid_y, {"id": 34, "building": null, "health": 3, "transition": {"id": 29, "building": null}})
	Grid.set_tile(mid_x-3, mid_y, {"id": 34, "building": null, "health": 3, "transition": {"id": 29, "building": null}})
	Grid.connect("grid_changed", self, "update_paving")
	var core = core_building.scene.instance()
	core.build(mid_x, mid_y, core_building.size)
	_buildings.add_child(core)
	Grid.connect("grid_changed", self, "update_chunk")
	Tasks.connect("tasks_changed", self, "update_tasks")
	label.text = Tasks.to_string()
	generate_chunks()

func generate_chunks():
	for x in range(0, floor(grid_size.x/Chunk.CHUNK_SIZE), 1):
		for y in range(0, floor(grid_size.y/Chunk.CHUNK_SIZE), 1):
			var chunk_pos = Vector3(x, 0, y)
			var chunk = Chunk.new()
			chunk.position = chunk_pos
			chunk.material = material
			_chunks[chunk_pos] = chunk
			_static.add_child(chunk)

func update_chunk(locations):
	for l in locations:
		var position = floor_vec3(l/Chunk.CHUNK_SIZE)
		if _chunks.has(position):
			_chunks[position].regenerate()
		var neighbours = [Vector3.FORWARD, Vector3.BACK, Vector3.LEFT, Vector3.RIGHT]
		for n in neighbours:
			var c_pos = floor_vec3((l+n)/Chunk.CHUNK_SIZE)
			if position != c_pos and _chunks.has(c_pos):
				_chunks[c_pos].regenerate()

func update_paving(locations):
	print(locations)
	for l in locations:
		var neighbours = [l+Vector3.FORWARD, l+Vector3.BACK, l+Vector3.LEFT, l+Vector3.RIGHT]
		var tile = Grid.get_tile(l.x, l.z)
		if tile.id == 29: # Paved, queue neighbours if they are walkable...
			for n in neighbours:
				var _tile = Grid.get_tile(n.x, n.z)
				if _tile.id != 29 and Grid.is_walkable(_tile):
					Tasks.add_queue_item("pave", Vector2(n.x, n.z), {"active_agents": [], "max_agents": 1})
		elif Grid.is_walkable(tile):
			var add_task = false
			for n in neighbours:
				var _tile = Grid.get_tile(n.x, n.z)
				if _tile.id == 29:
					add_task = true
			if add_task:
				Tasks.add_queue_item("pave", Vector2(l.x, l.z), {"active_agents": [], "max_agents": 1})

func update_tasks():
	label.text = Tasks.to_string()

func floor_vec3(vec): 
	return Vector3(floor(vec.x), floor(vec.y), floor(vec.z))
