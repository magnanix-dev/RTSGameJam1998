extends "res://assets/scripts/shared/State.gd"

export var task_tick_rate = 1
export var pave_damage = 1

func update(delta):
	.update(delta)

func tick(ticks):
	if ticks % task_tick_rate == 0:
		if owner.current_task != null:
			if Tasks.in_queue(owner.current_task.queue, owner.current_task.pos):
				owner.animator["parameters/Excavate/active"] = true
				Grid.damage_tile(owner.current_task.pos.x, owner.current_task.pos.y, pave_damage)
			else:
				owner.current_task = null
				owner.current_path = null
				emit_signal("finished", "idle")
		else:
			emit_signal("finished", "idle")
