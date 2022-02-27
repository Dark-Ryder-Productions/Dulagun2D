extends Node2D

export var is_left: bool = false

const NAME: String = "pistol"
const TYPE: String = "gun"
const IS_AUTO: bool = false

var is_firing: bool = false

func _ready():
	pass 


func _process(_delta):
	look_at(get_global_mouse_position())
	
###
# Fire a bullet where the gun is aiming
###
func fire():
	var bulletScene = load("res://Entities/Weapons/Bullet/Bullet.tscn")
	var bullet = bulletScene.instance()
	
	get_parent().add_child(bullet)
	$Gunshot.play()
	bullet.global_transform = $Muzzle.global_transform
