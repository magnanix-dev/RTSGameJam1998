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
	var wall = Tiles.get("dirt:wall")
	var ground = Tiles.get("dirt:ground")
	var dungeon_ground = Tiles.get("dungeon:ground")
	Grid.initialize(grid_size.x, grid_size.y, wall)
	var mid_x = floor(grid_size.x/2)
	var mid_y = floor(grid_size.y/2)
	Grid.connect("grid_changed", self, "update_paving")
	Grid.connect("grid_changed", self, "update_walls")
	Grid.set_tile(mid_x+3, mid_y, ground)
	Grid.set_tile(mid_x-3, mid_y, ground)
	Grid.set_region(mid_x, mid_y, 5, 5, dungeon_ground)
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
	var dungeon_ground = Tiles.get("dungeon:ground")
	for l in locations:
		var neighbours = [l+Vector3.FORWARD, l+Vector3.BACK, l+Vector3.LEFT, l+Vector3.RIGHT]
		var tile = Grid.get_tile(l.x, l.z)
		if tile.id == dungeon_ground.id: # Paved, queue neighbours if they are walkable...
			for n in neighbours:
				var _tile = Grid.get_tile(n.x, n.z)
				if _tile.id != dungeon_ground.id and Grid.is_walkable(n.x, n.z):
					Tasks.add_queue_item("claim", Vector2(n.x, n.z), {"active_agents": [], "max_agents": 1, "transition": dungeon_ground})
		elif Grid.is_walkable(l.x, l.z):
			var add_task = false
			for n in neighbours:
				var _tile = Grid.get_tile(n.x, n.z)
				if _tile.id == dungeon_ground.id:
					add_task = true
			if add_task:
				Tasks.add_queue_item("claim", Vector2(l.x, l.z), {"active_agents": [], "max_agents": 1, "transition": dungeon_ground})

func update_walls(locations):
	var dirt_wall = Tiles.get("dirt:wall")
	var dungeon_wall = Tiles.get("dungeon:wall")
	var dungeon_ground = Tiles.get("dungeon:ground")
	for l in locations:
		var neighbours = [l+Vector3.FORWARD, l+Vector3.BACK, l+Vector3.LEFT, l+Vector3.RIGHT]
		var tile = Grid.get_tile(l.x, l.z)
		if tile.id == dungeon_ground.id: # Paved, queue neighbours if they are dirt walls...
			for n in neighbours:
				var _tile = Grid.get_tile(n.x, n.z)
				if _tile.id == dirt_wall.id:
					Tasks.add_queue_item("reinforce", Vector2(n.x, n.z), {"active_agents": [], "max_agents": 1, "transition": dungeon_wall})

func update_tasks():
	label.text = Tasks.to_string()

func floor_vec3(vec): 
	return Vector3(floor(vec.x), floor(vec.y), floor(vec.z))
