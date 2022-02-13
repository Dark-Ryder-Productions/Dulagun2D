extends Node2D

export var is_left: bool = false

const TYPE: String = 'pistol'

func _ready():
	pass 


func _process(delta):
	look_at(get_global_mouse_position())
	
###
# Fire a bullet where the gun is aiming
###
func fire():
	var bulletScene = load("res://Entities/Weapons/Bullet/Bullet.tscn")
	var bullet = bulletScene.instance()
	
	add_child(bullet)
	bullet.transform = $Muzzle.transform
