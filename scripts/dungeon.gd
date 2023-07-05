extends Node3D

var Room = preload("res://scenes/room.tscn")

@onready var Map = $TileMap
@onready var Map3D = $NavigationRegion3D/GridMap
@onready var NavMap = $NavigationGridMap

var tile_size = 32
var num_rooms = 50
var min_size = 4
var max_size = 10
var hspread = 0
var vspread = 0
var cull = 0.4
var path
var rooms = []

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	make_rooms()

func make_rooms():
	var available_rooms = []
	hspread = randi_range(0, 400)
	vspread = randi_range(0, 400)
	for i in range(num_rooms):
		var pos = Vector2(randi_range(-hspread, hspread), randi_range(-vspread, vspread))
		var r = Room.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
		var w = min_size + randi() % (max_size - min_size)
		var h = min_size + randi() % (max_size - min_size)
		r.make_room(pos, Vector2(w, h) * tile_size)
		$Rooms.add_child(r)
		
	# Wait for movement to stop
	await get_tree().create_timer(1.1).timeout
	# Cull rooms
	var room_positions = []
	for room in $Rooms.get_children():
		if randf() < cull:
			room.queue_free()
		else:
			room_positions.append(Vector2(room.position.x, room.position.y))
			available_rooms.append(room)
	
	# Room type
	if available_rooms.size() > 0:
		# Designating exit room, there is only one
		var exit_room = available_rooms[randi() % available_rooms.size()]
		var boss_room = available_rooms[randi() % available_rooms.size()]
		var siriph_spawn = available_rooms[randi() % available_rooms.size()]
		exit_room.type = "exit_room"
		boss_room.type = "boss_room"
		siriph_spawn.type = "siriph_spawn"
		boss_room.boss = Globals.bosses[randi() % Globals.bosses.size()]
		available_rooms.erase(exit_room)
		available_rooms.erase(boss_room)
		available_rooms.erase(siriph_spawn)
		# Designating rooms
		# -- The rooms are sliced up into equal groups then for each time of room,
		#    a number out of the slice size is picked.
		var room_slices = floori(available_rooms.size() / 2)
		var room_config = {"loot_rooms": randi_range(1, room_slices), "trap_rooms": randi_range(1, room_slices)}
		for x in room_config["loot_rooms"]:
			var room_selection = randi_range(0, available_rooms.size() - 1)
			available_rooms[room_selection].type = "loot_room"
			available_rooms.erase(available_rooms[room_selection])
		for x in room_config["trap_rooms"]:
			var room_selection = randi_range(0, available_rooms.size() - 1)
			available_rooms[room_selection].type = "trap_room"
			available_rooms[room_selection].trap_type = Globals.trap_types[randi() % Globals.trap_types.size()]
			available_rooms.erase(available_rooms[room_selection])
		print(room_config)
		
	await get_tree().create_timer(1.1).timeout	
	path = find_mst(room_positions)
	make_map()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _draw():
	pass
				
func _process(delta):
	pass
	
func _input(event):
	if event.is_action_pressed("ui_select"):
		pass

func find_mst(nodes):
	# Prim's algorithm
	var path = AStar2D.new()
	path.add_point(path.get_available_point_id(), nodes.pop_front())

	while nodes:
		var min_dist = INF
		var min_p = null
		var p = null
		
		for px in path.get_point_ids():
			var p1 = path.get_point_position(px)
			for p2 in nodes:
				if p1.distance_to(p2) < min_dist:
					min_dist = p1.distance_to(p2)
					min_p = p2
					p = p1
		var n = path.get_available_point_id()
		path.add_point(n, min_p)
		path.connect_points(path.get_closest_point(p), n)
		nodes.erase(min_p)
	return path

func make_map():
	Map.clear()
	
	# Filling the map with the dungeon wall
	var full_rect = Rect2()
	for room in $Rooms.get_children():
		var r = Rect2(room.position - room.size, room.get_node("CollisionShape2D").shape.extents * 2)
		full_rect = full_rect.merge(r)
	var topleft = Map.local_to_map(full_rect.position)
	var bottomright = Map.local_to_map(full_rect.end)
	for x in range(topleft.x, bottomright.x):
		for y in range(topleft.y, bottomright.y):
			pass
			Map.set_cell(0, Vector2i(x, y), 1, Vector2i.ZERO)
	
	# Making the room
	var corridors = []
	for room in $Rooms.get_children():
		var s = (room.size / tile_size).floor()
		var pos = Map.local_to_map(room.position)
		var ul = (room.position / tile_size).floor() - s
		for x in range(2, s.x * 2 - 1):
			for y in range(2, s.y * 2 - 1):
				Map.set_cell(0, Vector2i(ul.x + x, ul.y + y), 2, Vector2i.ZERO)
				Map3D.set_cell_item(Vector3i(ul.x + x, 0, ul.y + y), 0)
				rooms.append(Vector2i(ul.x + x, ul.y + y))
		
		# Making the corridors/pathways		
		var p = path.get_closest_point(Vector2(room.position.x, room.position.y))
		
		for conn in path.get_point_connections(p):
			if not conn in corridors:
				var start = Map.local_to_map(Vector2(path.get_point_position(p).x, path.get_point_position(p).y))
				var end = Map.local_to_map(Vector2(path.get_point_position(conn).x, path.get_point_position(conn).y))
				
				carve_path(start, end)
				
			corridors.append(p)
			
	for tile in Map.get_used_cells(0):
		if Map.get_cell_source_id(0, tile) == 1:
			Map3D.set_cell_item(Vector3i(tile.x, 0, tile.y), -1)
			if check_neighbouring(2, tile):
				Map3D.set_cell_item(Vector3i(tile.x, 0, tile.y), -1)
			else:
				for w in 2:
					Map3D.set_cell_item(Vector3i(tile.x, w, tile.y), 1)

	map_second_pass()
	
func map_second_pass():
	for room in $Rooms.get_children():
		var empty = randi_range(0, 2)
		var enemy = null
		if empty < 2:
			enemy = Globals.enemies[randi() % Globals.enemies.size()]
		print(str(empty))
		var s = (room.size / tile_size).floor()
		var pos = Map.local_to_map(room.position)
		var ul = (room.position / tile_size).floor() - s
		for x in range(2, s.x * 2 - 1):
			for y in range(2, s.y * 2 - 1):
				Map.set_cell(0, Vector2i(ul.x + x, ul.y + y), 2, Vector2i.ZERO)
				Map3D.set_cell_item(Vector3i(ul.x + x, 0, ul.y + y), 0)
				rooms.append(Vector2i(ul.x + x, ul.y + y))
				
				# Objects ----------------------
				
				if randi_range(0, 1) == 1:
					# Lights
					var light_scene = load("res://objects/light.tscn")
					if x == 2 or x == s.x * 2 - 2:
						if y == ceili(((s.y * 2 - 1) - 2) / 2):
							if Map3D.get_cell_item(Vector3i(ul.x + x - 1, 1, ul.y + y)) == 1 or Map3D.get_cell_item(Vector3i(ul.x + x + 1, 1, ul.y + y)) == 1:
								if x == 2:
									Map3D.set_cell_item(Vector3(ul.x + x - 1, 1, ul.y + y), 2, 22)
								elif x == s.x * 2 - 2:
									Map3D.set_cell_item(Vector3(ul.x + x + 1, 1, ul.y + y), 2, 16)
								#Map3D.set_cell_item(Vector3i(ul.x + x, 2, ul.y + y), 1)
								var light = light_scene.instantiate()
								#light.omni_range = 2000
								light.global_position = Map3D.map_to_local(Vector3i(ul.x + x, 1, ul.y + y))
								add_child(light)
					
					if y == 2 or y == s.y * 2 - 2:
						if x == ceili(((s.x * 2 - 1) - 2) / 2):
							if Map3D.get_cell_item(Vector3i(ul.x + x, 1, ul.y + y - 1)) == 1 or Map3D.get_cell_item(Vector3i(ul.x + x, 1, ul.y + y + 1)) == 1:
								if y == 2:
									Map3D.set_cell_item(Vector3(ul.x + x, 1, ul.y + y - 1), 2, 10)
								elif y == s.y * 2 - 2:
									Map3D.set_cell_item(Vector3(ul.x + x, 1, ul.y + y + 1), 2)
								var light = light_scene.instantiate()
								#light.omni_range = 2000
								light.global_position = Map3D.map_to_local(Vector3i(ul.x + x, 1, ul.y + y))
								add_child(light)
						
				# ----------------------------------------
				
				# Spawning entities ----------------------
				
				if empty == 0 and room.type != "boss_room" and room.type != "trap_room":
					match enemy:
						"skeleton":
							# Skelleton
							if randi_range(0, 100) < 5:
								if randi_range(0, 5) < 4:
									var skeleton = Globals.skeleton_scene.instantiate()
									skeleton.global_position = Map3D.map_to_local(Vector3i(ul.x + x, 1, ul.y + y))
									add_child(skeleton)
								else:
									var skeleton_mage = Globals.skeleton_mage_scene.instantiate()
									skeleton_mage.global_position = Map3D.map_to_local(Vector3i(ul.x + x, 1, ul.y + y))
									add_child(skeleton_mage)
						"rat":
							# Rat
							if randi_range(0, 100) < 3:
								var rat = Globals.rat_scene.instantiate()
								rat.global_position = Map3D.map_to_local(Vector3i(ul.x + x, 1, ul.y + y))
								add_child(rat)
						"skeleton_mage":
							if randi_range(0, 100) < 3:
								var skeleton_mage = Globals.skeleton_mage_scene.instantiate()
								skeleton_mage.global_position = Map3D.map_to_local(Vector3i(ul.x + x, 1, ul.y + y))
								add_child(skeleton_mage)
				elif room.type == "boss_room" and randi_range(0, 100) < 10:
					var coins_scene = load("res://objects/coins.tscn")
					var coins = coins_scene.instantiate()
					coins.global_position =  Map3D.map_to_local(Vector3i(ul.x + x, 1, ul.y + y))
					coins.position.y -= 0.5
					add_child(coins)
				elif room.type == "trap_room":
					if room.trap_type == "trap_pressure_plate" and randi_range(0, 100) < 5:
						var trap_pressure_plate_scene = load("res://objects/trap_pressure_plate.tscn")
						var trap_pressure_plate = trap_pressure_plate_scene.instantiate()
						trap_pressure_plate.global_position = Map3D.map_to_local(Vector3i(ul.x + x, 1, ul.y + y))
						trap_pressure_plate.position.y -= 0.5
						add_child(trap_pressure_plate)
					
								
				var xx = (s.x * 2 - 2) - 2
				var yy = (s.y * 2 - 2) - 2
				if room.type == "loot_room" and x == xx / 2 + 2 and y == yy / 2 + 2:
					# Add loot chest
					var chest_scene = load("res://objects/chest.tscn")
					var chest = chest_scene.instantiate()
					chest.global_position = Map3D.map_to_local(Vector3i(ul.x + x, 1, ul.y + y))
					chest.position.y -= 0.5
					add_child(chest)
					
				elif room.type == "exit_room" and x == xx / 2 + 2 and y == yy / 2 + 2:
					# Add exit ladder
					var ladder_scene = load("res://objects/ladder.tscn")
					var ladder = ladder_scene.instantiate()
					ladder.global_position = Map3D.map_to_local(Vector3i(ul.x + x, 1, ul.y + y))
					ladder.position.y -= 0.5
					add_child(ladder)
					
				elif room.type == "boss_room" and x == xx / 2 + 2 and y == yy / 2 + 2:
					# Spawn random boss
					var boss_scene = room.boss
					var boss = boss_scene.instantiate()
					boss.global_position = Map3D.map_to_local(Vector3i(ul.x + x, 1, ul.y + y))
					#boss.position.y += 1.5
					add_child(boss)
				elif room.type == "siriph_spawn" and x == xx / 2 + 2 and y == yy / 2 + 2:
					# Spawn siriph
					var siriph_scene = load("res://entities/siriph.tscn")
					var siriph = siriph_scene.instantiate()
					siriph.global_position = Map3D.map_to_local(Vector3i(ul.x + x, 1, ul.y + y))
					add_child(siriph)
					print("spawned siriph")
					
				if room.type == null:
					var room_objects = randi_range(0, 100)
					if room_objects < 10:
						var pot_scene = load("res://objects/pot.tscn")
						var pot = pot_scene.instantiate()
						pot.global_position = Map3D.map_to_local(Vector3i(ul.x + x, 1, ul.y + y))
						pot.position.y -= 0.5
						add_child(pot)
						$Player.global_position = Map3D.map_to_local(Vector3i(ul.x + x, 1, ul.y + y))
					elif room_objects > 50 and x == xx / 2 + 2 and y == yy / 2 + 2:
						var campfire_scene = load("res://objects/campfire.tscn")
						var campfire = campfire_scene.instantiate()
						campfire.global_position = Map3D.map_to_local(Vector3i(ul.x + x, 1, ul.y + y))
						campfire.position.y -= 0.5
						add_child(campfire)
						
				
	
	$NavigationRegion3D.bake_navigation_mesh(false)
	$Rooms.queue_free()

func delete_nav(object):
	var new_door = object.duplicate()
	new_door.status = "opened"
	#add_child(new_door)
	object.queue_free()
	$NavigationRegion3D.bake_navigation_mesh(false)

func check_neighbouring(tileQuery, tileCompare):
	if (Map.get_cell_source_id(0, Map.get_neighbor_cell(tileCompare, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE)) != tileQuery and
			Map.get_cell_source_id(0, Map.get_neighbor_cell(tileCompare, TileSet.CELL_NEIGHBOR_TOP_SIDE)) != tileQuery and
			Map.get_cell_source_id(0, Map.get_neighbor_cell(tileCompare, TileSet.CELL_NEIGHBOR_LEFT_SIDE)) != tileQuery and
			Map.get_cell_source_id(0, Map.get_neighbor_cell(tileCompare, TileSet.CELL_NEIGHBOR_RIGHT_SIDE)) != tileQuery and
			Map.get_cell_source_id(0, Map.get_neighbor_cell(tileCompare, TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER)) != tileQuery and
			Map.get_cell_source_id(0, Map.get_neighbor_cell(tileCompare, TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER)) != tileQuery and 
			Map.get_cell_source_id(0, Map.get_neighbor_cell(tileCompare, TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER)) != tileQuery and
			Map.get_cell_source_id(0, Map.get_neighbor_cell(tileCompare, TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER)) != tileQuery):
		return true
	else:
		return false

# Tiling the corridors/pathways
func carve_path(pos1, pos2):
	var has_rats = randi_range(0, 1)
	var x_diff = sign(pos2.x - pos1.x)
	var y_diff = sign(pos2.y - pos1.y)
	if x_diff == 0: x_diff = pow(-1.0, randi() % 2)
	if y_diff == 0: y_diff = pow(-1.0, randi() % 2)
	
	var x_y = pos1
	var y_x = pos2
	
	if (randi() % 2) > 0:
		x_y = pos2
		y_x = pos1
	for x in range(pos1.x, pos2.x, x_diff):
		Map.set_cell(0, Vector2i(x, x_y.y), 2, Vector2i(0, 0))
		Map.set_cell(0, Vector2i(x, x_y.y + y_diff), 2, Vector2i(0, 0))
		
		Map3D.set_cell_item(Vector3i(x, 0, x_y.y), 0)
		Map3D.set_cell_item(Vector3i(x, 0, x_y.y + y_diff), 0)
		
		# Adding doors on x axis
		if rooms.has(Vector2i(x, x_y.y)) == false and rooms.has(Vector2i(x, x_y.y + y_diff)) == false:
			if ((rooms.has(Vector2i(x + 1, x_y.y)) == true and rooms.has(Vector2i(x + 1, x_y.y + y_diff)) == true)
			or (rooms.has(Vector2i(x - 1, x_y.y)) == true and rooms.has(Vector2i(x - 1, x_y.y + y_diff)) == true)):
				if randi_range(0, 1) != 0:
					#Map3D.set_cell_item(Vector3i(x, 1, x_y.y), 2, 22)
					#Map3D.set_cell_item(Vector3i(x, 1, x_y.y + y_diff), 2, 22)
					var doorscene = load("res://objects/door.tscn")
					var door = doorscene.instantiate()
					door.global_position = Map3D.map_to_local(Vector3i(x, 1, x_y.y))
					door.rotation_degrees = Vector3(door.rotation_degrees.x, -90, door.rotation_degrees.y)
					add_child(door)
					var door1 = doorscene.instantiate()
					door1.global_position = Map3D.map_to_local(Vector3i(x, 1, x_y.y + y_diff))
					door1.rotation_degrees = Vector3(door1.rotation_degrees.x, -90, door1.rotation_degrees.y)
					add_child(door1)
			else:
				if has_rats == 1:
					if randi_range(0, 100) < 50:
						var rat = Globals.rat_scene.instantiate()
						rat.global_position = Map3D.map_to_local(Vector3i(x, 1, x_y.y))
						add_child(rat)

	for y in range(pos1.y, pos2.y, y_diff):
		Map.set_cell(0, Vector2i(y_x.x, y), 2, Vector2i(0, 0))
		Map.set_cell(0, Vector2i(y_x.x + x_diff, y), 2, Vector2i(0, 0))
		
		Map3D.set_cell_item(Vector3i(y_x.x, 0, y), 0)
		Map3D.set_cell_item(Vector3i(y_x.x + x_diff, 0, y), 0)
		
		# Adding doors on y axis
		if rooms.has(Vector2i(y_x.x, y)) == false and rooms.has(Vector2i(y_x.x + x_diff, y)) == false:
			if ((rooms.has(Vector2i(y_x.x, y + 1)) == true and rooms.has(Vector2i(y_x.x + x_diff, y + 1)) == true)
			or (rooms.has(Vector2i(y_x.x, y - 1)) == true and rooms.has(Vector2i(y_x.x + x_diff, y - 1)) == true)):
				if randi_range(0, 1) != 0:
					#Map3D.set_cell_item(Vector3i(y_x.x, 1, y), 2)
					#Map3D.set_cell_item(Vector3i(y_x.x + x_diff, 1, y), 2)
					var doorscene = load("res://objects/door.tscn")
					var door = doorscene.instantiate()
					door.global_position = Map3D.map_to_local(Vector3i(y_x.x, 1, y))
					add_child(door)
					var door1 = doorscene.instantiate()
					door1.global_position = Map3D.map_to_local(Vector3i(y_x.x + x_diff, 1, y))
					add_child(door1)
			else:
				if has_rats == 1:
					if randi_range(0, 100) < 10:
						var rat = Globals.rat_scene.instantiate()
						rat.global_position = Map3D.map_to_local(Vector3i(y_x.x, 1, y))
						add_child(rat)
