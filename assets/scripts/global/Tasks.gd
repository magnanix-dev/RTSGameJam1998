extends Node

signal tasks_changed

var queues = {}

func in_queue(queue, key):
	if queues.has(queue):
		if queues[queue].has(key):
			return true

func get_queue_item(queue, key):
	if in_queue(queue, key):
		return queues[queue][key]

func add_queue_item(queue, key, item):
	if not queues.has(queue):
		queues[queue] = {}
	queues[queue][key] = item
	emit_signal("tasks_changed")

func remove_queue_item(queue, key):
	if in_queue(queue, key):
		queues[queue].erase(key)
	emit_signal("tasks_changed")

func to_string():
	var string = ["Tasks:"]
	for queue in queues:
		string.append("  " + str(queue))
		for item in queues[queue]:
			string.append("    " + str(item))
	return PoolStringArray(string).join("\n")
