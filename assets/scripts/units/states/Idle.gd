extends "Motion.gd"

export var idle_max_ticks = 4
export var task_check_rate = 1
export var fickle = 4

var idle_count = 0

func enter():
	idle_count = 0
	owner.current_task = null
	owner.current_path = []
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
	if idle_count > 0: idle_count -= 1
	var tasks = Tasks.request(owner.grid_location(), owner) # Proximity Task Request
	var fickle_check = randi() % fickle
	var fickle_count = 0
	var potential_task = null
	var potential_path = []
	for t in tasks:
		if Pathfinder.viable_path(owner.grid_location(), t.pos):
			potential_task = t
			potential_path = Pathfinder.find_path(owner.grid_location(), t.pos)
			fickle_count += (fickle-t.priority)
			if fickle_count >= fickle_check: break
	if potential_task != null: owner.current_task = potential_task
	if potential_path.size(): owner.current_path = potential_path
	if owner.current_task != null and owner.current_path.size():
		var task = Tasks.get_queue_item(owner.current_task.queue, owner.current_task.pos)
		if task != null:
			if not task.active_agents.has(owner):
				if task.active_agents.size() < task.max_agents:
					task.active_agents.append(owner)
				else:
					owner.current_task = null
					owner.current_path = []
	if not owner.current_path.size() and idle_count == 0:
		if randf() < 0.5:
			owner.current_path = Pathfinder.random_path(owner.grid_location())
		else:
			idle_count = randi() % idle_max_ticks
	if owner.current_path.size():
		emit_signal("finished", "path")
