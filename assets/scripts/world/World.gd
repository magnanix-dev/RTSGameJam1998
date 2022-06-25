extends Node

export var grid_size = Vector2.ZERO
export (Resource) var material

onready var pivot = $"../Pivot"
onready var label = $"../Label"

var _chunks = {}

func _ready():
	pivot.transform.origin = Vector3(floor(grid_size.x/2), 0, floor(grid_size.y/2))
	Grid.initialize(grid_size.x, grid_size.y, 35)
	var mid_x = floor(grid_size.x/2)
	var mid_y = floor(grid_size.y/2)
	for x in range(mid_x-4, mid_x+4, 1):
		for y in range(mid_y-4, mid_y+4, 1):
			Grid.tiles[x][y] = 34
	Grid.connect("grid_changed", self, "update_chunk")
	generate_chunks()

func generate_chunks():
	for x in range(0, floor(grid_size.x/Chunk.CHUNK_SIZE), 1):
		for y in range(0, floor(grid_size.y/Chunk.CHUNK_SIZE), 1):
			var chunk_pos = Vector3(x, 0, y)
			var chunk = Chunk.new()
			chunk.position = chunk_pos
			chunk.material = material
			_chunks[chunk_pos] = chunk
			add_child(chunk)

func update_chunk(location):
	var position = floor_vec3(location/Chunk.CHUNK_SIZE)
	if _chunks.has(position):
		_chunks[position].regenerate()
	var neighbours = [Vector3.FORWARD, Vector3.BACK, Vector3.LEFT, Vector3.RIGHT]
	for n in neighbours:
		var c_pos = floor_vec3((location+n)/Chunk.CHUNK_SIZE)
		if position != c_pos and _chunks.has(c_pos):
			_chunks[c_pos].regenerate()

func floor_vec3(vec): 
	return Vector3(floor(vec.x), floor(vec.y), floor(vec.z))
