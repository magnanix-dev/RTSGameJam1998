extends "Motion.gd"

export var movespeed = 1.0
export var task_check_rate = 1

var target = Vector3.ZERO
var target_direction = Vector3.ZERO
var path_index = 1

func enter():
	target = Vector3.ZERO
	target_direction = Vector3.ZERO
	path_index = 1
	run()

func update(delta):
	if owner.current_path.size():
		if path_index < owner.current_path.size():
			if not target:
				path_target()
		else:
			path_finished()
	else:
		path_finished()
	if target:
		var distance = (target - owner.global_transform.origin)
		if not target_direction: target_direction = distance.normalized()
		if distance.length() < 0.05:
			target = Vector3.ZERO
			target_direction = Vector3.ZERO
			path_index += 1
		else:
			velocity = target_direction
	if velocity:
		owner.move_and_slide(velocity * movespeed, Vector3.UP)
	owner.debug_text.text += "\nPathing: " + str(path_index) + " / " + str(owner.current_path.size()-1)
	.update(delta)

func path_target():
	var current = owner.current_path[path_index]
	if not Grid.is_walkable(current.x, current.y):
		owner.current_path = []
	target = Grid.to_world(current.x, current.y) + Vector3(rand_range(0.3, 0.7), 0, rand_range(0.3, 0.7))

func path_finished():
	target = Vector3.ZERO
	target_direction = Vector3.ZERO
	velocity = Vector3.ZERO
	if owner.current_task != null:
		emit_signal("finished", owner.current_task.queue)
	else:
		emit_signal("finished", "idle")

func tick(ticks):
	if ticks % task_check_rate == 0:
		run()

func run():
	if not Tasks.in_queue(owner.current_task.queue, owner.current_task.pos) or owner.current_task == null:
		owner.current_task = null
		owner.current_path = []
		emit_signal("finished", "idle")
