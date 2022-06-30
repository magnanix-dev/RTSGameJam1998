extends Node

signal player_registered
signal ui_registered
signal containers_registered

var player
var ui
var _static
var _dynamic
var _buildings
var _units

func register_player(entity):
	player = entity
	emit_signal("player_registered", player)
	
func register_ui(entity):
	ui = entity
	emit_signal("ui_registered", ui)
	
func register_containers(__static, __dynamic, __buildings, __units):
	_static = __static
	_dynamic = __dynamic
	_buildings = __buildings
	_units = __units
	emit_signal("containers_registered", [_static, _dynamic, _buildings, _units])
