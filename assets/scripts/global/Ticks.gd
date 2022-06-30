extends Node

var tickrate = 1.0

var tick = 0.0
var ticks = 0

var entities = []

func _process(delta):
	tick += delta
	if tick >= tickrate:
		tick -= tickrate
		tick()

func tick():
	ticks += 1
	for e in entities:
		e.tick(ticks)

func register(entity):
	if entity.has_method("tick"):
		entities.append(entity)
