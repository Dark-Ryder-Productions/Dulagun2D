extends KinematicBody2D

export var gravity: int = 80
export var speed: int = 10
export var health: int = 40

var is_dead: bool = false
var player_spotted: bool = false
var player = null


func _ready():
	add_to_group("enemies")

func _process(delta):
	if is_dead:
		return
	
	var vel = Vector2()
	vel.y += gravity * delta
	
	if player_spotted and !is_dead:
		# For whatever reason this is sometimes still getting called after the instance is freed
		# Fix this
		var posToPlayerDiff = player.global_position - global_position

		vel.x = posToPlayerDiff.x * delta
		
	vel.x *= speed
	move_and_slide(vel)
	
###
# Take damage
###
func apply_damage(damage):
	health -= damage
	if health <= 0:
		die()
		
###
# Sucks to suck
###	
func die():
	is_dead = true
	# This is temporary until I add death animations and all that jazz
	queue_free()


func _on_Search_body_entered(body):
	player_spotted = true
	player = body
