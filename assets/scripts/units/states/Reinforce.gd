extends "res://assets/scripts/shared/State.gd"

export var rotatespeed = 5.0
export var task_tick_rate = 1
export var conversion_rate = 1

var direction = Vector3.ZERO

func enter():
	owner.animator["parameters/Reinforce/blend_amount"] = 1.0

func exit():
	owner.animator["parameters/Reinforce/blend_amount"] = 0.0

func update(delta):
	if owner.current_task != null:
		direction = (Grid.to_world(owner.current_task.pos.x, owner.current_task.pos.y) + Vector3(0.5, 0, 0.5)) - owner.transform.origin
	if direction:
		owner.facing = lerp(owner.facing, direction, delta * rotatespeed)
		owner.mesh.look_at(owner.transform.origin - owner.facing, Vector3.UP)
	.update(delta)

func tick(ticks):
	if ticks % task_tick_rate == 0:
		if owner.current_task != null:
			if Tasks.in_queue(owner.current_task.queue, owner.current_task.pos):
				#owner.animator["parameters/Reinforce/active"] = true
				Grid.convert_tile(owner.current_task.pos.x, owner.current_task.pos.y, conversion_rate)
			else:
				owner.current_task = null
				owner.current_path = []
				emit_signal("finished", "idle")
		else:
			emit_signal("finished", "idle")
