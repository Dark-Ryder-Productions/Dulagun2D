extends Node2D

export var fire_rate: float = 0.7
export var is_left: bool = false

const NAME: String = "shotgun"
const TYPE: String = "gun"
const IS_AUTO: bool = false

var is_firing: bool = false

func _ready():
	pass 

func _process(delta):
	look_at(get_global_mouse_position())
	
###
# Fire a bullet where the gun is aiming
###
func fire():
	if is_firing:
		return
	
	is_firing = true
	# Placeholder until pellets are added
	var bulletScene = load("res://Entities/Weapons/Bullet/Bullet.tscn")
	$Muzzle.rotation_degrees = 0
	$Gunshot.play()
	
	# Spread pellets in 5 increments between a min and max degree
	for degrees in range(-5, 5, 1):
		var bullet = bulletScene.instance()
		get_parent().add_child(bullet)
		$Muzzle.rotation_degrees = degrees
		bullet.global_transform = $Muzzle.global_transform
	
	yield(get_tree().create_timer(fire_rate), "timeout")
	is_firing = false
