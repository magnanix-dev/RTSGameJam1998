extends Spatial

var speed = 16.0
var rotate_speed = 4.0

onready var camera = $Camera
onready var omni = $OmniLight
var drop_plane = null
var mouse_grid
var mouse_position

func _unhandled_input(event):
	if event.is_action_pressed("action_primary"):
		dig()

func dig():
	get_mouse()
	if Grid.in_grid(mouse_grid.x, mouse_grid.z):
		Grid.set_tile(mouse_grid.x, mouse_grid.z, 12)

func get_mouse():
	if not drop_plane:
		drop_plane = Plane(Vector3(0, 1, 0), global_transform.origin.y+0.5)
	var mouse_pos = get_viewport().get_mouse_position()
	var mouse_loc = drop_plane.intersects_ray(camera.project_ray_origin(mouse_pos), camera.project_ray_normal(mouse_pos)*100)
	
	mouse_grid = Vector3(floor(mouse_loc.x), 0, floor(mouse_loc.z))
	mouse_position = Vector3((mouse_loc.x), 0, (mouse_loc.z))

func get_direction():
	var forward = transform.basis.z.normalized()
	var right = -forward.cross(Vector3.UP)
	var direction = Vector3.ZERO
	direction += (Input.get_action_strength("strafe_right") - Input.get_action_strength("strafe_left")) * right
	direction += (Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")) * forward
	return direction.normalized()

func _physics_process(delta):
	var direction = get_direction()
	if direction != Vector3.ZERO:
		transform.origin += (direction * speed) * delta
	get_mouse()
	omni.global_transform.origin = lerp(omni.global_transform.origin, mouse_position, speed/2 * delta)
	rotate_y((Input.get_action_strength("move_left")-Input.get_action_strength("move_right")) * rotate_speed * delta)
