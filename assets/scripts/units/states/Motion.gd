extends "res://assets/scripts/shared/State.gd"

export var rotatespeed = 5.0
var velocity = Vector3.ZERO
var direction = Vector3.ZERO
var facing = Vector3.ZERO

func update(delta):
	if velocity: direction = velocity
	owner.animator["parameters/Velocity/blend_amount"] = velocity.length() / 1.25
	if direction:
		owner.facing = lerp(owner.facing, direction, delta * rotatespeed)
		owner.mesh.look_at(owner.transform.origin - owner.facing, Vector3.UP)
