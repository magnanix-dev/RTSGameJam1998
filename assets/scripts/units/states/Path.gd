extends "Motion.gd"

export var move_speed = 0.75
export var task_speed_multiplier = 1.375
var movespeed = 1.0

export var task_check_rate = 1
export var fickle = 4

var target = Vector3.ZERO
var target_direction = Vector3.ZERO
var distance = 0
var path_index = 1

var collision = null
var collisions = 0
var collision_max = 10

func enter():
	movespeed = move_speed
	if owner.current_task != null: movespeed *= task_speed_multiplier
	target = Vector3.ZERO
	target_direction = Vector3.ZERO
	path_index = 1
	collisions = 0
	run()

func update(delta):
	if path_index > owner.current_path.size() - 1:
		path_finished()
	if owner.current_path.size():
		if path_index < owner.current_path.size():
			if not target:
				path_target()
	else:
		path_finished()
	if target:
		distance = (target - owner.transform.origin)
		if not target_direction: target_direction = distance.normalized()
		if distance.length() < 0.05:
			path_next()
		else:
			velocity = target_direction
	if velocity:
		collision = owner.move_and_collide(velocity * movespeed * delta)
		if collision and distance.length() < 1:
			path_next()
			collisions += 1
		if collisions >= collision_max: path_finished()
	owner.debug_text.text += "\nPathing: " + str(path_index) + " / " + str(owner.current_path.size()-1)
	.update(delta)

func path_next():
	target = Vector3.ZERO
	target_direction = Vector3.ZERO
	path_index += 1

func path_target():
	var current = owner.current_path[path_index]
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
	if owner.current_task != null and not Tasks.in_queue(owner.current_task.queue, owner.current_task.pos):
		owner.current_task = null
		owner.current_path = []
		emit_signal("finished", "idle")
	elif owner.current_task == null:
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
		if owner.current_task != null and owner.current_path.size():
			enter()
