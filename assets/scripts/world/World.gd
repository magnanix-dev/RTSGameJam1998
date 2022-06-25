extends Node

const CHUNK_MIDPOINT = Vector3(0.5, 0.5, 0.5) * Chunk.CHUNK_SIZE
const CHUNK_END_SIZE = Chunk.CHUNK_SIZE - 1

export var test_render = 3


var render_distance setget _set_render_distance
var _delete_distance = 0
var effective_render_distance = 0
var _old_chunk = Vector3()

var _generating = true
var _deleting = false

var _chunks = {}

onready var pivot = $"../Pivot"

func _process(_delta):
	_set_render_distance(test_render)
	var current_chunk = (pivot.transform.origin / Chunk.CHUNK_SIZE).round()
	
	if _deleting or current_chunk != _old_chunk:
		_delete_far_chunks(current_chunk)
		_generating = true
	
	if not _generating:
		return
	
	#current_chunk.y += round(clamp(pivot.transform.origin.y, -render_distance / 4, render_distance / 4))
	
	for x in range(current_chunk.x - effective_render_distance, current_chunk.x + effective_render_distance):
		for y in range(current_chunk.y - effective_render_distance, current_chunk.y + effective_render_distance):
			for z in range(current_chunk.z - effective_render_distance, current_chunk.z + effective_render_distance):
				var chunk_position = Vector3(x, y, z)
				if current_chunk.distance_to(chunk_position) > render_distance:
					continue
				if _chunks.has(chunk_position):
					continue
				var chunk = Chunk.new()
				chunk.world = self
				chunk.chunk_position = chunk_position
				_chunks[chunk_position] = chunk
				add_child(chunk)
				return
	
	if effective_render_distance < render_distance:
		effective_render_distance += 1
	else:
		_generating = false

func get_block_at(position):
	var chunk_position = (position / Chunk.CHUNK_SIZE).floor()
	if _chunks.has(chunk_position):
		var chunk = _chunks[chunk_position]
		var sub_pos = position.posmod(Chunk.CHUNK_SIZE)
		if chunk.data.has(sub_pos):
			return chunk.data[sub_pos]
	return 0

func set_block_at(position, id):
	var chunk_position = (position / Chunk.CHUNK_SIZE).floor()
	var chunk = _chunks[chunk_position]
	var sub_pos = position.postmode(Chunk.CHUNK_SIZE)
	if id == 0:
		chunk.data.erase(sub_pos)
	else:
		chunk.data[sub_pos] = id
	chunk.redraw()
	
	if Chunk.is_block_void(id):
		if sub_pos.x == 0:
			_chunks[chunk_position + Vector3.LEFT].regenerate()
		elif sub_pos.x == CHUNK_END_SIZE:
			_chunks[chunk_position + Vector3.RIGHT].regenerate()
		if sub_pos.z == 0:
			_chunks[chunk_position + Vector3.FORWARD].regenerate()
		elif sub_pos.z == CHUNK_END_SIZE:
			_chunks[chunk_position + Vector3.BACK].regenerate()
		if sub_pos.y == 0:
			_chunks[chunk_position + Vector3.DOWN].regenerate()
		elif sub_pos.y == CHUNK_END_SIZE:
			_chunks[chunk_position + Vector3.UP].regenerate()

func clean_up():
	for chunk_key in _chunks.keys():
		var thread = _chunks[chunk_key]._thread
		if thread:
			thread.wait_to_finish()
	_chunks = {}
	set_process(false)
	for c in get_children():
		c.free()

func _set_render_distance(value):
	render_distance = value
	_delete_distance = value + 2

func _delete_far_chunks(chunk):
	_old_chunk = chunk
	effective_render_distance = max(1, effective_render_distance-1)
	
	var deleted_this_frame = 0
	var max_deletions = clamp(2*(render_distance - effective_render_distance), 2, 8)
	
	for chunk_key in _chunks.keys():
		if chunk.distance_to(chunk_key) > _delete_distance:
			var thread = _chunks[chunk_key]._thread
			if thread:
				thread.wait_to_finish()
			_chunks[chunk_key].queue_free()
			_chunks.erase(chunk_key)
			deleted_this_frame += 1
			if deleted_this_frame > max_deletions:
				_deleting = true
				return
	
	_deleting = false
