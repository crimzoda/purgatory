extends GridMap

var all_points = {}
var _as = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func init_cells():
	_as = AStar3D.new()
	var cells = get_used_cells()
	print("used cells: " + str(cells))
	for cell in cells:
		var ind = _as.get_available_point_id()
		_as.add_point(ind, map_to_local(Vector3i(cell.x, cell.y, cell.z)))
		all_points[v3_to_index(cell)] = ind
	
	for cell in cells:
		for x in [-1, 0, 1]:
			for y in [-1, 0, 1]:
				for z in [-1, 0, 1]:
					var v3 = Vector3i(x, y, z)
					if v3 == Vector3i(0, 0, 0):
						continue
					if v3_to_index(v3 + cell) in all_points:
						var ind1 = all_points[v3_to_index(cell)]
						var ind2 = all_points[v3_to_index(cell + v3)]
						if !_as.are_points_connected(ind1, ind2):
							_as.connect_points(ind1, ind2, true)

func v3_to_index(v3):
	return str(int(round(v3.x))) + "," + str(int(round(v3.y))) + "," + str(int(round(v3.z)))

func _get_path(start, end):
	var gm_start = v3_to_index(local_to_map(start))
	var gm_end = v3_to_index(local_to_map(end))
	var start_id = 0
	var end_id = 0
	if gm_start in all_points:
		start_id = all_points[gm_start]
	else:
		start_id = _as.get_closest_point(start)
	if gm_end in all_points:
		end_id = all_points[gm_end]
	else:
		end_id = _as.get_closest_point(end)
		
	print(str(gm_start) + " to " + str(gm_end) + ", all points: " + str(all_points))
		
	return _as.get_point_path(start_id, end_id)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
