extends OmniLight

export var max_energy = 10.0
export var max_range = 5.0
export var speed = 1.0

onready var noise = OpenSimplexNoise.new()
var value = 0.0
var max_value = 10000

func _ready():
	value = randi() % max_value
	noise.period = 16

func _process(delta):
	value += speed
	if value > max_value:
		value = 0.0
	var energy = ((noise.get_noise_1d(value) +1) / 4.0) + 0.5
	light_energy = energy * max_energy
	omni_range = energy * max_range
