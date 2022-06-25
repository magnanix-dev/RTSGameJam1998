extends StaticBody
class_name Chunk

const CHUNK_SIZE = 16
const TEXTURE_SHEET_WIDTH = 8

const CHUNK_LAST_INDEX = CHUNK_SIZE - 1
const TEXTURE_TILE_SIZE = 1.0 / TEXTURE_SHEET_WIDTH

var block_atlas = preload("res://assets/materials/material.tres")

var data = {}
var chunk_position = Vector3.ZERO

var _thread

var world

func _ready():
	transform.origin = chunk_position * CHUNK_SIZE
	name = str(chunk_position)
	data = DungeonGenerator.flat(chunk_position)
	
	#_generate_collider()
	
	_thread = Thread.new()
	_thread.start(self, "_generate_mesh")

func redraw():
	for c in get_children():
		remove_child(c)
		c.queue_free()
		
	#_generate_collider()
	_generate_mesh()

func _generate_collider():
	if data.empty():
		_create_block_collider(Vector3.ZERO)
		collision_layer = 0
		collision_mask = 0
		return
	collision_layer = 0xFFFFF
	collision_mask = 0xFFFFF
	for pos in data.keys():
		var id = data[pos]
		if not is_block_void(id):
			_create_block_collider(pos)
	
	
func _generate_mesh():
	if data.empty():
		return
	var surface = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for pos in data.keys():
		var id = data[pos]
		_draw_block_mesh(surface, pos, id)
	
	surface.generate_normals()
	#surface.generate_tangents()
	surface.index()
	var arrmesh = surface.commit()
	print(arrmesh)
	var mesh = MeshInstance.new()
	mesh.mesh = arrmesh
	mesh.material_override = block_atlas
	#mesh.create_trimesh_collision()

func _draw_block_mesh(surface, pos, id):
	var verts = calculate_block_verts(pos)
	var uvs = calculate_block_uvs(id)
	var top_uvs = uvs
	var bottom_uvs = uvs
	
	if is_block_void(id):
		_draw_block_face(surface, [verts[2], verts[0], verts[7], verts[5]], uvs)
		_draw_block_face(surface, [verts[7], verts[5], verts[2], verts[0]], uvs)
		_draw_block_face(surface, [verts[3], verts[1], verts[6], verts[4]], uvs)
		_draw_block_face(surface, [verts[6], verts[4], verts[3], verts[1]], uvs)
		return
	
	var o_pos = null
	var o_id = null
	
	o_pos = pos + Vector3.LEFT
	o_id = 0
	if o_pos.x == -1:
		o_id = world.get_block_at(o_pos+chunk_position*CHUNK_SIZE)
	elif data.has(o_pos):
		o_id = data[o_pos]
	if id != o_id and is_block_void(o_id):
		_draw_block_face(surface, [verts[2], verts[0], verts[3], verts[1]], uvs)
	
	o_pos = pos + Vector3.RIGHT
	o_id = 0
	if o_pos.x == CHUNK_SIZE:
		o_id = world.get_block_at(o_pos+chunk_position*CHUNK_SIZE)
	elif data.has(o_pos):
		o_id = data[o_pos]
	if id != o_id and is_block_void(o_id):
		_draw_block_face(surface, [verts[7], verts[5], verts[6], verts[4]], uvs)
	
	o_pos = pos + Vector3.FORWARD
	o_id = 0
	if o_pos.z == -1:
		o_id = world.get_block_at(o_pos+chunk_position*CHUNK_SIZE)
	elif data.has(o_pos):
		o_id = data[o_pos]
	if id != o_id and is_block_void(o_id):
		_draw_block_face(surface, [verts[6], verts[4], verts[2], verts[0]], uvs)
	
	o_pos = pos + Vector3.BACK
	o_id = 0
	if o_pos.z == CHUNK_SIZE:
		o_id = world.get_block_at(o_pos+chunk_position*CHUNK_SIZE)
	elif data.has(o_pos):
		o_id = data[o_pos]
	if id != o_id and is_block_void(o_id):
		_draw_block_face(surface, [verts[3], verts[1], verts[7], verts[5]], uvs)
	
	o_pos = pos + Vector3.DOWN
	o_id = 0
	if o_pos.y == -1:
		o_id = world.get_block_at(o_pos+chunk_position*CHUNK_SIZE)
	elif data.has(o_pos):
		o_id = data[o_pos]
	if id != o_id and is_block_void(o_id):
		_draw_block_face(surface, [verts[4], verts[5], verts[0], verts[1]], bottom_uvs)
	
	o_pos = pos + Vector3.UP
	o_id = 0
	if o_pos.y == CHUNK_SIZE:
		o_id = world.get_block_at(o_pos+chunk_position*CHUNK_SIZE)
	elif data.has(o_pos):
		o_id = data[o_pos]
	if id != o_id and is_block_void(o_id):
		_draw_block_face(surface, [verts[2], verts[3], verts[6], verts[7]], top_uvs)

func _create_block_collider(position):
	var collider = CollisionShape.new()
	collider.shape = BoxShape.new()
	collider.shape.extents = Vector3.ONE / 2
	collider.transform.origin = position + Vector3.ONE / 2
	add_child(collider)

func _draw_block_face(surface, verts, uvs):
	surface.add_uv(uvs[1]); surface.add_vertex(verts[1])
	surface.add_uv(uvs[2]); surface.add_vertex(verts[2])
	surface.add_uv(uvs[3]); surface.add_vertex(verts[3])

	surface.add_uv(uvs[2]); surface.add_vertex(verts[2])
	surface.add_uv(uvs[1]); surface.add_vertex(verts[1])
	surface.add_uv(uvs[0]); surface.add_vertex(verts[0])

static func calculate_block_uvs(id):
	var row = id / TEXTURE_SHEET_WIDTH
	var col = id % TEXTURE_SHEET_WIDTH
	
	return [
		TEXTURE_TILE_SIZE * Vector2(col, row),
		TEXTURE_TILE_SIZE * Vector2(col, row+1),
		TEXTURE_TILE_SIZE * Vector2(col+1, row),
		TEXTURE_TILE_SIZE * Vector2(col+1, row+1),
	]

static func calculate_block_verts(pos):
	return [
		Vector3(pos.x, pos.y, pos.z),
		Vector3(pos.x, pos.y, pos.z+1),
		Vector3(pos.x, pos.y+1, pos.z),
		Vector3(pos.x, pos.y+1, pos.z+1),
		Vector3(pos.x+1, pos.y, pos.z),
		Vector3(pos.x+1, pos.y, pos.z+1),
		Vector3(pos.x+1, pos.y+1, pos.z),
		Vector3(pos.x+1, pos.y+1, pos.z+1),
	]

static func is_block_void(id):
	var void_ids = [0]
	return void_ids.has(id)
