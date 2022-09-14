extends PathFollow2D

signal base_damage(damage)

var speed = 150
var hp = 60
var base_damage = 21

onready var health_bar = get_node("HealthBar")
onready var impact_area = get_node("Impact")
var projectile_impact = preload("res://Scenes/SupportScenes/ProjectileImpact.tscn")

func _ready():
	randomize() # randomize seed for random-number generator
	health_bar.max_value = hp
	health_bar.value = hp
	health_bar.set_as_toplevel(true) # disconnect HealthBar position/rotation/scale/etc from parent node

func _physics_process(delta):
	if unit_offset == 1.0:
		emit_signal("base_damage", base_damage)
		queue_free()
	move(delta)
	
func move(delta):
	set_offset(get_offset() + (speed * delta))
	health_bar.set_position(position - Vector2(30, 30)) # reset health_bar position, subtract so we correctly position health bar above tank again

func on_hit(damage):
	impact()
	hp -= damage
	health_bar.value = hp
	if hp <= 0:
		on_destroy()

func impact():
	var x_pos = randi() % 31 # constrain X to size of tank (end exclusive)
	var y_pos = randi() % 31 # constrain Y to size of tank (end exclusive)
	var impact_location = Vector2(x_pos, y_pos)
	var new_impact = projectile_impact.instance()
	new_impact.position = impact_location
	impact_area.add_child(new_impact)

func on_destroy():
	# remove the tank so the turret doesn't keep firing at it, but keep it
	# on screen 0.2 seconds longer so we can finish showing the final impact
	# animation
	get_node("KinematicBody2D").queue_free()
	yield(get_tree().create_timer(0.2), "timeout")
	self.queue_free()
