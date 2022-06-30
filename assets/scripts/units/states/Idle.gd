extends "Motion.gd"

export var task_check_rate = 1
export var fickle = 4

func enter():
	run()

func update(delta):
	.update(delta)

func tick(ticks):
	if owner.current_task != null and owner.current_path.size():
		var task = Tasks.get_queue_item(owner.current_task.queue, owner.current_task.pos)
		if task != null:
			if not task.active_agents.has(owner):
				if task.active_agents.size() < task.max_agents:
					task.active_agents.append(owner)
				else:
					owner.current_task = null
					owner.current_path = []
					return
			emit_signal("finished", "path")
	if ticks % task_check_rate == 0 and owner.current_task == null:
		run()

func run():
	var tasks = Tasks.request(owner.grid_location(), owner) # Proximity Task Request
	print(tasks)
	var fickle_check = randi() % fickle
	var fickle_count = 0
	for t in tasks:
		if Pathfinder.viable_path(owner.grid_location(), t.pos):
			owner.current_task = t
			owner.current_path = Pathfinder.find_path(owner.grid_location(), t.pos)
			fickle_count += 1
			if fickle_count >= fickle_check: break
	if owner.current_task != null and owner.current_path.size():
		var task = Tasks.get_queue_item(owner.current_task.queue, owner.current_task.pos)
		if task != null:
			if not task.active_agents.has(owner):
				if task.active_agents.size() < task.max_agents:
					task.active_agents.append(owner)
				else:
					owner.current_task = null
					owner.current_path = []
					return
			emit_signal("finished", "path")
