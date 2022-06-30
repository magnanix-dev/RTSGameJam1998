extends Resource
class_name Tile

export (String) var name
export (int) var id
export (int) var conversion # health

export (bool) var is_void = false
export (bool) var is_walkable = false

export (Texture) var icon
export (Mesh) var custom_mesh = null
export (Vector2) var top_subdivisions = Vector2(1, 1)
export (Vector2) var side_subdivisions = Vector2(1, 1)
