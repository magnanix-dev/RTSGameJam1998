extends "res://assets/scripts/shared/State.gd"

export var rotatespeed = 5.0
export var task_tick_rate = 1
export var excavate_conversion = 1

var direction = Vector3.ZERO

func update(delta):
	if owner.current_task != null:
		direction = (Grid.to_world(owner.current_task.pos.x, owner.current_task.pos.y) + Vector3(0.5, 0, 0.5)) - owner.global_transform.origin
	if direction:
		owner.facing = lerp(owner.facing, direction, delta * rotatespeed)
		owner.mesh.look_at(owner.global_transform.origin - owner.facing, Vector3.UP)
	.update(delta)

func tick(ticks):
	if ticks % task_tick_rate == 0:
		if owner.current_task != null:
			if Tasks.in_queue(owner.current_task.queue, owner.current_task.pos):
				owner.animator["parameters/Excavate/active"] = true
				Grid.convert_tile(owner.current_task.pos.x, owner.current_task.pos.y, excavate_conversion)
			else:
				owner.current_task = null
				owner.current_path = null
				emit_signal("finished", "idle")
		else:
			emit_signal("finished", "idle")
