extends StaticBody
class_name Chunk

const CHUNK_SIZE = 10

const TEXTURE_WIDTH = 8
const TEXTURE_TILE = 1.0 / TEXTURE_WIDTH

var position = Vector3.ZERO
var material = null

var vertices = []
var uvs = []
var indices = []

var _thread

func _ready():
	name = "Chunk: " + str(position)
	
	build_data()
	_thread = Thread.new()
	_thread.start(self, "generate_mesh")
	_thread.wait_to_finish()
	
	generate_collider()

func regenerate():
	for c in get_children():
		remove_child(c)
		c.queue_free()
	
	build_data()
	_thread.start(self, "generate_mesh")
	_thread.wait_to_finish()
	
	generate_collider()

func build_data():
	vertices = []
	uvs = []
	indices = []
	var pos = position * CHUNK_SIZE
	for x in range(pos.x, pos.x+CHUNK_SIZE, 1):
		for y in range(pos.z, pos.z+CHUNK_SIZE, 1):
			var points = cube_points(Vector3(x, 1, y))
			var tile = Grid.get_tile(x, y)
			var uv_points = cube_uvs(tile.id)
			if tile.custom_mesh != null:
				# Add code to pull obj/mesh data and append it to the surface tool... Potentially add a 9x9 autotile
				pass
			else:
				if Grid.is_void(x, y):
					add_face([points[4], points[5], points[6], points[7]], uv_points, tile.top_subdivisions) #e,f,g,h
				else:
					add_face([points[0], points[1], points[2], points[3]], uv_points, tile.top_subdivisions) #a,b,c,d
					if Grid.in_grid(x+1, y) and Grid.is_void(x+1, y):
						add_face([points[2], points[1], points[5], points[6]], uv_points, tile.side_subdivisions) #b,f,g,c
					if Grid.in_grid(x-1, y) and Grid.is_void(x-1, y):
						add_face([points[0], points[3], points[7], points[4]], uv_points, tile.side_subdivisions) #a,d,h,e
					if Grid.in_grid(x, y-1) and Grid.is_void(x, y-1):
						add_face([points[1], points[0], points[4], points[5]], uv_points, tile.side_subdivisions) #b,a,e,f
					if Grid.in_grid(x, y+1) and Grid.is_void(x, y+1):
						add_face([points[3], points[2], points[6], points[7]], uv_points, tile.side_subdivisions) #d,c,g,h

func generate_collider():
	for c in get_children():
		c.create_trimesh_collision()

func generate_mesh():
	var surface = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for i in range(indices.size()):
		surface.add_uv(uvs[i])
		surface.add_vertex(vertices[indices[i]])
	
	surface.generate_normals()
	surface.generate_tangents()
	surface.index()
	
	var instance = MeshInstance.new()
	instance.mesh = surface.commit()
	instance.material_override = material
	
	add_child(instance)

func cube_points(pos, size = 1):
	var points = []
	points.append(Vector3(pos.x, pos.y, pos.z)) #a
	points.append(Vector3(pos.x+size, pos.y, pos.z)) #b
	points.append(Vector3(pos.x+size, pos.y, pos.z+size)) #c
	points.append(Vector3(pos.x, pos.y, pos.z+size)) #d
	
	points.append(Vector3(pos.x, pos.y-size, pos.z)) #e
	points.append(Vector3(pos.x+size, pos.y-size, pos.z)) #f
	points.append(Vector3(pos.x+size, pos.y-size, pos.z+size)) #g
	points.append(Vector3(pos.x, pos.y-size, pos.z+size)) #h
	return points

func cube_uvs(id):
	var r = id / TEXTURE_WIDTH
	var c = id % TEXTURE_WIDTH
	
	return [
		TEXTURE_TILE * Vector2(c, r),
		TEXTURE_TILE * Vector2(c+1, r),
		TEXTURE_TILE * Vector2(c+1, r+1),
		TEXTURE_TILE * Vector2(c, r+1),
	]

func add_face(verts, uv, subdivision = Vector2(1, 1)):
	var x_inc = (verts[1] - verts[0]) / subdivision.x
	var y_inc = (verts[2] - verts[1]) / subdivision.y
	var uv_x_inc = (uv[1] - uv[0]) / subdivision.x
	var uv_y_inc = (uv[2] - uv[1]) / subdivision.y
	for row in range(subdivision.y):
		var start = verts[0] + row*y_inc
		var start_uv = uv[0] + row*uv_y_inc
		for col in range(subdivision.x):
			start = start + col*x_inc
			start_uv = start_uv + col*uv_x_inc
			add_quad([start, start+x_inc, start+x_inc+y_inc, start+y_inc], [start_uv, start_uv+uv_x_inc, start_uv+uv_x_inc+uv_y_inc, start_uv+uv_y_inc])

func add_quad(verts, uv):
	var vi1 = _add_vert(verts[0])
	var vi2 = _add_vert(verts[1])
	var vi3 = _add_vert(verts[2])
	var vi4 = _add_vert(verts[3])
	
	uvs.append(uv[0])
	indices.append(vi1)
	uvs.append(uv[1])
	indices.append(vi2)
	uvs.append(uv[2])
	indices.append(vi3)
	
	uvs.append(uv[0])
	indices.append(vi1)
	uvs.append(uv[2])
	indices.append(vi3)
	uvs.append(uv[3])
	indices.append(vi4)

func _add_vert(vert):
	vertices.append(vert)
	return vertices.size()-1
