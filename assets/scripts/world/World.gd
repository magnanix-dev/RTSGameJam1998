extends Spatial

export var grid_size = Vector2.ZERO
export (Resource) var material

export (Resource) var core_building

onready var pivot = $Dynamic/Pivot
onready var label = $Label

onready var _static = $Static
onready var _dynamic = $Dynamic
onready var _buildings = $Buildings

var _chunks = {}

func _ready():
	pivot.transform.origin = Vector3(floor(grid_size.x/2)+0.5, 0, floor(grid_size.y/2))
	Grid.initialize(grid_size.x, grid_size.y, {"id": 35, "building": null})
	var mid_x = floor(grid_size.x/2)
	var mid_y = floor(grid_size.y/2)
	for x in range(mid_x-2, mid_x+3, 1):
		for y in range(mid_y-2, mid_y+3, 1):
			Grid.set_tile(x, y, {"id": 34, "building": null})
	Grid.set_tile(mid_x+3, mid_y, {"id": 34, "building": null})
	Grid.set_tile(mid_x-3, mid_y, {"id": 34, "building": null})
	var core = core_building.scene.instance()
	core.global_transform.origin = Grid.to_world(mid_x, mid_y)
	_buildings.add_child(core)
	Grid.set_region(mid_x, mid_y, core_building.size, {"id": 0, "building": core})
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

func update_chunk(location):
	var position = floor_vec3(location/Chunk.CHUNK_SIZE)
	if _chunks.has(position):
		_chunks[position].regenerate()
	var neighbours = [Vector3.FORWARD, Vector3.BACK, Vector3.LEFT, Vector3.RIGHT]
	for n in neighbours:
		var c_pos = floor_vec3((location+n)/Chunk.CHUNK_SIZE)
		if position != c_pos and _chunks.has(c_pos):
			_chunks[c_pos].regenerate()

func update_tasks():
	label.text = Tasks.to_string()

func floor_vec3(vec): 
	return Vector3(floor(vec.x), floor(vec.y), floor(vec.z))
