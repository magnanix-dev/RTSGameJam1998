extends "res://assets/scripts/shared/State.gd"

export var task_tick_rate = 1
export var conversion_rate = 1

func enter():
	owner.animator["parameters/Claim/blend_amount"] = 1.0

func exit():
	owner.animator["parameters/Claim/blend_amount"] = 0.0

func update(delta):
	.update(delta)

func tick(ticks):
	if ticks % task_tick_rate == 0:
		if owner.current_task != null:
			if Tasks.in_queue(owner.current_task.queue, owner.current_task.pos):
				#owner.animator["parameters/Claim/active"] = true
				Grid.convert_tile(owner.current_task.pos.x, owner.current_task.pos.y, conversion_rate)
			else:
				owner.current_task = null
				owner.current_path = []
				emit_signal("finished", "idle")
		else:
			emit_signal("finished", "idle")
