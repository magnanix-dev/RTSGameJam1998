extends OmniLight

export var max_energy = 5.0
export var min_energy = 1.0
export var max_range = 10.0
export var min_range = 5.0

export var speed_energy = 1.0
export var speed_range = 1.0

var current_energy = 0.0
var direction_energy = 1.0
var current_range = 0.0
var direction_range = 1.0

func _ready():
	current_energy = max_energy
	current_range = max_range
	light_energy = current_energy
	omni_range = current_range

func _process(delta):
	current_energy += (delta * speed_energy) * direction_energy
	current_range += (delta * speed_range) * direction_range
	if current_energy <= min_energy: direction_energy = 1.0
	if current_energy >= max_energy: direction_energy = -1.0
	if current_range <= min_range: direction_range = 1.0
	if current_range >= max_range: direction_range = -1.0
	light_energy = current_energy
	omni_range = current_range
