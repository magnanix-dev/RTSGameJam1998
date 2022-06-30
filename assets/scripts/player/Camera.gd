extends Spatial

export var speed = 16.0
export var rotate_speed = 4.0

onready var debug_text = $Debug
onready var camera = $Camera
onready var omni = $OmniLight
onready var hover_plane = $Hover_Plane
onready var hover_block = $Hover_Block
var drop_plane = null
var mouse_grid
var mouse_position

export (PackedScene) var dig_scene
var active_plans = []
var inactive_plans = []
var plan_buffer = null

var filling = false

func _ready():
	omni.set_as_toplevel(true)
	hover_plane.set_as_toplevel(true)
	hover_block.set_as_toplevel(true)
	prepare_plans(64)

func request_plan():
	var p = inactive_plans.pop_front()
	active_plans.push_back(p)
	p.visible = true
	return p

func release_plan(plan):
	var found = null
	for p in active_plans:
		if p == plan:
			found = p
	found.visible = false
	inactive_plans.push_back(found)
	active_plans.erase(found)

func prepare_plans(count):
	if plan_buffer == null:
		plan_buffer = Spatial.new()
		add_child(plan_buffer)
		plan_buffer.set_as_toplevel(true)
	for i in range(count):
		var p = dig_scene.instance()
		p.visible = false
		plan_buffer.add_child(p)
		inactive_plans.push_back(p)

func _unhandled_input(event):
	if event.is_action_pressed("action_primary"):
		primary_action()

func primary_action():
	get_mouse()
	if Grid.in_grid(mouse_grid.x, mouse_grid.z):
		var building = Grid.get_building(mouse_grid.x, mouse_grid.z)
		if building != null:
			if building.has_method("toggle_ui"):
				building.toggle_ui()
		else:
			if not Grid.is_void(mouse_grid.x, mouse_grid.z):
				excavate(mouse_grid.x, mouse_grid.z)

func excavate(x, y):
	var ground = Tiles.get("dirt:ground")
	var vector = Vector2(x, y)
	if Tasks.in_queue("excavate", vector):
		var task = Tasks.get_queue_item("excavate", vector)
		if task != null:
			release_plan(task.reference)
		Tasks.remove_queue_item("excavate", vector)
	else:
		var p = request_plan()
		p.owner = self
		p.transform.origin = Grid.to_world(x, y) + Vector3.UP
		Tasks.add_queue_item("excavate", vector, {"reference": p, "active_agents": [], "max_agents": 2, "transition": ground})

func get_mouse():
	if not drop_plane:
		drop_plane = Plane(Vector3(0, 1, 0), transform.origin.y+1)
	var mouse_pos = get_viewport().get_mouse_position()
	var mouse_loc = drop_plane.intersects_ray(camera.project_ray_origin(mouse_pos), camera.project_ray_normal(mouse_pos)*100)
	
	mouse_grid = Vector3(floor(mouse_loc.x), 0, floor(mouse_loc.z))
	mouse_position = Vector3((mouse_loc.x), 0, (mouse_loc.z))
	debug_text.rect_position = mouse_pos + Vector2(-20, 0)
#	if Grid.in_grid(mouse_grid.x, mouse_grid.z):
#		var tile = Grid.get_tile(mouse_grid.x, mouse_grid.z)
#		if "conversion" in tile:
#			debug_text.text = str(tile.conversion)
#		else:
#			debug_text.text = ""

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
	if Grid.in_grid(mouse_grid.x, mouse_grid.z):
		if Grid.is_void(mouse_grid.x, mouse_grid.z):
			if filling: hover_block.visible = true
			hover_plane.visible = false
		else:
			hover_block.visible = false
			if not filling:
				hover_plane.visible = true
			else:
				hover_plane.visible = false
	omni.transform.origin = lerp(omni.transform.origin, mouse_position + Vector3(0, 2, 0), speed * 2 * delta)
	hover_plane.transform.origin = mouse_grid + Vector3(0, 1.1, 0)
	hover_block.transform.origin = mouse_grid + Vector3(0, 0.1, 0)
	rotate_y((Input.get_action_strength("move_left")-Input.get_action_strength("move_right")) * rotate_speed * delta)
