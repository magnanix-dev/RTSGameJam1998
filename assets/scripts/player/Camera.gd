extends Spatial

var speed = 16.0

func get_direction():
	var direction = Vector3.ZERO
	direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	direction.z = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	return direction

func _physics_process(delta):
	var direction = get_direction()
	if direction != Vector3.ZERO:
		transform.origin += (direction * (delta * speed))
