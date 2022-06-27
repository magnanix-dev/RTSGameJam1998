extends Resource
class_name Building

export (String) var name
export (bool) var buildable = true
export (Vector2) var size = Vector2(1, 1)
export (String) var cost

export (Texture) var icon
export (PackedScene) var scene
