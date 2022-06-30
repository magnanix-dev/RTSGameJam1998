extends Node

signal tasks_changed

var queues = {}

func in_queue(queue, key):
	if queues.has(queue):
		if queues[queue].has(key):
			return true
	return false

func get_queue_item(queue, key):
	if in_queue(queue, key):
		return queues[queue][key]
	return null

func add_queue_item(queue, key, item):
	if not queues.has(queue):
		queues[queue] = {}
	if not in_queue(queue, key):
		queues[queue][key] = item
	emit_signal("tasks_changed")

func remove_queue_item(queue, key):
	if in_queue(queue, key):
		queues[queue].erase(key)
	emit_signal("tasks_changed")

func request(location = null, caller = null):
	if location != null: # Proximity Task Request
		var tasks = get_relevant_tasks(location, caller)
		tasks.sort_custom(self, "sort_distance")
		tasks.sort_custom(self, "sort_priority")
		return tasks
	else: # Global Task Request
		return []

func get_relevant_tasks(location, caller = null):
	var items = []
	for queue in queues:
		if caller != null and not queue in caller.states:
			continue
		for i in queues[queue]:
			var item = queues[queue][i]
			var priority = 0
			if "priority" in caller:
				priority = caller.priority[queue]
			items.append({"queue": queue, "pos": i, "distance": i.distance_to(location), "priority": priority})
	return items

func sort_distance(a, b):
	if a.distance < b.distance:
		return true
	return false

func sort_priority(a, b):
	if a.priority > b.priority:
		return true
	return false

func to_string():
	var string = ["Tasks:"]
	for queue in queues:
		string.append("  " + str(queue))
		for item in queues[queue]:
			string.append("    " + str(item))
	return PoolStringArray(string).join("\n")
