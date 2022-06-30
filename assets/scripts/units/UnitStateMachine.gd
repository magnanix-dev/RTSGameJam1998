extends KinematicBody
class_name UnitStateMachine

signal state_changed

var current_task = null
var current_path = []

onready var debug_text = $Debug
onready var mesh = $Mesh
onready var animator = mesh.get_child(0).animation

var facing = Vector3.ZERO

var current_state
var stack = []
onready var states = {
	'idle': $States/Idle,
	'path': $States/Path,
	'excavate': $States/Excavate,
	'claim': $States/Claim,
	'reinforce': $States/Reinforce,
}

var priority = { # Lower Number = Higher Priority
	'excavate': 0,
	'claim': 1,
	'reinforce': 2
}

func _ready():
	for node in $States.get_children():
		node.connect("finished", self, "_change_state")
	stack.push_front(states.idle)
	current_state = stack[0]
	_change_state("idle")
	Ticks.register(self)

func spawn(pos):
	transform.origin = pos + Vector3(0.5, 0, 0.5)

func _physics_process(delta):
	debug_text.rect_position = get_viewport().get_camera().unproject_position(transform.origin) + Vector2(-512, 0)
	var queue = str(current_task.queue).capitalize() + "..." if current_task != null else "Idling..."
	debug_text.text = "Name: " + name + "\nState: " + current_state.name.capitalize()# + "\nTask: " + queue# + "\n" + str(current_path)
	current_state.update(delta)

func tick(ticks):
	current_state.tick(ticks)

func _change_state(state):
	if current_state: current_state.exit()
	
	if state == "previous":
		stack.pop_front()
	elif state in ["combat"]:
		stack.push_front(states[state])
	else:
		var new = states[state]
		stack[0] = new
	
	current_state = stack[0]
	if state != "previous":
		current_state.enter()
	else:
		current_state.resume()
	
	emit_signal("state_changed", stack)

func grid_location():
	return Vector2(floor(transform.origin.x), floor(transform.origin.z))
