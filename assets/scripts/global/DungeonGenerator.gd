extends Resource
class_name DungeonGenerator

const CHUNK_SIZE = 16

static func empty():
	return {}

static func flat(chunk_position):
	var data = {}
	
	if chunk_position.y != -1:
		return data
	
	for x in range(CHUNK_SIZE):
		for z in range(CHUNK_SIZE):
			data[Vector3(x, 0, z)] = 3
	
	return data
