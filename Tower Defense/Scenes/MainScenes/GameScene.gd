extends Node2D

signal game_finished(result)

var map_node

var build_mode = false
var build_valid = false
var build_tile
var build_location
var build_type

var current_wave = 0
var enemies_in_wave = 0

var base_health = 100

func _ready():
	map_node = get_node("Map1")
	
	for btn_node in get_tree().get_nodes_in_group("build_buttons"):
		btn_node.connect("pressed", self, "initiate_build_mode", [btn_node.get_name()])
	
func _process(delta):
	if build_mode:
		update_tower_preview()
	
func _unhandled_input(event):
	if event.is_action_released("ui_cancel") and build_mode:
		cancel_build_mode()
	elif event.is_action_released("ui_accept") and build_mode:
		verify_and_build()
		cancel_build_mode()

#################
# Wave Functions
#################

func start_next_wave():
	var wave_data = retrieve_wave_data()
	yield(get_tree().create_timer(0.2), "timeout") # time between waves
	spawn_enemies(wave_data)
	
func retrieve_wave_data():
	var wave_data = [["BlueTank", 1.0], ["BlueTank", 1.0], ["BlueTank", 1.0], ["BlueTank", 1.0], ["BlueTank", 1.0]]
	current_wave += 1
	enemies_in_wave = wave_data.size()
	return wave_data
	
func spawn_enemies(wave_data):
	for item in wave_data:
		var new_enemy = load("res://Scenes/Enemies/" + item[0] + ".tscn").instance()
		new_enemy.connect("base_damage", self, "on_base_damage")
		map_node.get_node("Path").add_child(new_enemy, true)
		yield(get_tree().create_timer(item[1]), "timeout")

##################
# Build Functions
##################

func initiate_build_mode(tower_type):
	if build_mode:
		cancel_build_mode()
	build_mode = true
	build_type = tower_type + "T1"
	get_node("UI").set_tower_preview(build_type, get_global_mouse_position())
	
func update_tower_preview():
	var mouse_position = get_global_mouse_position()
	var current_tile = map_node.get_node("TowerExclusion").world_to_map(mouse_position)
	var tile_position = map_node.get_node("TowerExclusion").map_to_world(current_tile)
	
	if map_node.get_node("TowerExclusion").get_cellv(current_tile) == -1:
		build_valid = true
		build_tile = current_tile
		build_location = tile_position
		get_node("UI").update_tower_preview(tile_position, "ad54ff3c")
	else:
		build_valid = false
		get_node("UI").update_tower_preview(tile_position, "adff4545")
	
func cancel_build_mode():
	build_mode = false
	build_valid = false
	get_node("UI/TowerPreview").free()
	
func verify_and_build():
	if build_valid:
		var new_tower = load("res://Scenes/Turrets/" + build_type + ".tscn").instance()
		new_tower.position = build_location
		new_tower.built = true
		new_tower.type = build_type
		new_tower.category = GameData.tower_data[build_type]["category"]
		map_node.get_node("Turrets").add_child(new_tower, true)
		var invisible_tile = 5
		map_node.get_node("TowerExclusion").set_cellv(build_tile, invisible_tile)

func on_base_damage(damage):
	base_health -= damage
	if base_health <= 0:
		emit_signal("game_finished", false)
	else:
		get_node("UI").update_health_bar(base_health)
