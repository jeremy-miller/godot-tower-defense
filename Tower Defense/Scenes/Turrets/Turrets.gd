extends Node2D

var type
var category
var enemy_array = []
var built = false
var enemy
var ready = true

func _ready():
	if built:
		self.get_node("Range/CollisionShape2D").get_shape().radius = 0.5 * GameData.tower_data[type]["range"]

func _physics_process(delta):
	if enemy_array.size() != 0 and built:
		select_enemy()
		if not get_node("AnimationPlayer").is_playing():
			turn()
		if ready:
			fire()
	else:
		enemy = null

func turn():
	get_node("Turret").look_at(enemy.position)

func select_enemy():
	var enemy_progress_array = []
	for e in enemy_array:
		enemy_progress_array.append(e.offset) # offset = distance along path this enemy has traveled
	var max_offset = enemy_progress_array.max()
	var enemy_index = enemy_progress_array.find(max_offset) # target the enemy furthest along the path
	enemy = enemy_array[enemy_index]

func fire():
	ready = false
	if category == "projectile":
		fire_gun()
	elif category == "missile":
		fire_missile()
	enemy.on_hit(GameData.tower_data[type]["damage"])
	yield(get_tree().create_timer(GameData.tower_data[type]["rate_of_fire"]), "timeout")
	ready = true

func fire_gun():
	get_node("AnimationPlayer").play("Fire")
	
func fire_missile():
	pass

func _on_Range_body_entered(body):
	enemy_array.append(body.get_parent()) # append parent since that's the Path2D the turrent needs to track

func _on_Range_body_exited(body):
	enemy_array.erase(body.get_parent())
