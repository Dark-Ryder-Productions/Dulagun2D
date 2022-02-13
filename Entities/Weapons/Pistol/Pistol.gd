extends Node2D

export var is_left: bool = false

const type: String = 'pistol'

func _ready():
	pass 


func _process(delta):
	look_at(get_global_mouse_position())
	
func fire():
	print("Pow")
