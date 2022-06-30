extends Node

var checked = {}
var astars = {}
var sectors = []

func _ready():
	Grid.connect("grid_changed", self, "_get_walkable")
	_get_walkable()

func random_path(start):
	var sector = null
	var path = []
	for i in range(sectors.size()):
		if sectors[i].has(start):
			sector = i
	if sector != null:
		var valid = false
		var iterations = 0
		while not valid and iterations < sectors[sector].size():
			var random_index = randi() % sectors[sector].size()
			if sectors[sector][random_index] != start:
				path = find_path(start, sectors[sector][random_index])
				valid = true
			iterations += 1
	return path

func viable_path(start, end):
	var viable = false
	for i in range(sectors.size()):
		if sectors[i].has(start) and sectors[i].has(end):
			viable = true
			break
	return viable

func find_path(start, end):
	var sector = null
	for i in range(sectors.size()):
		if sectors[i].has(start) and sectors[i].has(end):
			sector = i
			break
	if sector != null:
		return astars[sector].get_point_path(point_index(start), point_index(end))
	return []

func _get_walkable(_grid = null):
	checked = {}
	sectors = []
	for a in astars:
		astars[a].clear()
	for x in range(Grid.size_x):
		for y in range(Grid.size_y):
			if not Vector2(x, y) in checked:
				if Grid.is_walkable(x, y):
					var sector = _walk_sector(Vector2(x, y), [])
					sectors.append(sector)
	for i in range(sectors.size()):
		var astar
		if astars.has(i) and astars[i] is AStar2D:
			astar = astars[i]
		else:
			astar = AStar2D.new()
		var points = sectors[i]
		for p in points:
			astar.add_point(point_index(p), p, 1)
		for p in points:
			if not Grid.is_walkable(p.x, p.y): continue
			var base_index = point_index(p)
			var neighbours = [p + Vector2.UP, p + Vector2.RIGHT, p + Vector2.DOWN, p + Vector2.LEFT]
			for n in neighbours:
				var n_index = point_index(n)
				if astar.has_point(n_index):
					astar.connect_points(base_index, n_index, false)
		astars[i] = astar

func point_index(vector):
	return vector.x + Grid.size_x * vector.y

func _walk_sector(vector, sector = []):
	checked[vector] = true
	sector.append(vector)
	var dirs = [vector + Vector2.UP, vector + Vector2.RIGHT, vector + Vector2.DOWN, vector + Vector2.LEFT]
	for dir in dirs:
		if not sector.has(dir):
			if Grid.is_walkable(dir.x, dir.y):
				sector = _walk_sector(dir, sector)
			elif not Grid.is_void(dir.x, dir.y):
				sector.append(dir)
	return sector
