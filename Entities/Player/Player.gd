extends KinematicBody2D

export var speed: int = 500
export var in_air_speed_modifier: float = 0.02
export var accel: float = 0.25

# Movement constants
const JUMP_FORCE: int = -600
const GRAVITY: int = 1200
const WALL_SLIDE: int = 300

# Movement properties
var vel: Vector2 = Vector2()
var prior_x_vel: float
var is_wall_sliding: bool = false

# Weapon constants
const PISTOL = "pistol"

# Weapon handling
var aval_weapons = [ PISTOL ]
var weapon_res_map = {
	PISTOL: "res://Entities/Weapons/Pistol/Pistol.tscn"
}
var left_weapon = null
var right_weapon = null

onready var sprite = $AnimatedSprite

func _ready():
	pass 

func _physics_process(delta):
	var inputXVel = 0
	
	# movement inputs
	if Input.is_action_pressed("move_left"):
		inputXVel = -1
	if Input.is_action_pressed("move_right"):
		inputXVel = 1
		
	# jump input
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			vel.y = JUMP_FORCE
		elif is_on_wall():
			vel.y = JUMP_FORCE
			prior_x_vel = -prior_x_vel
			
	# gravity
	if is_on_wall():
		if !is_wall_sliding:
			# Cancel vertical velocity when player initially collides with a wall
			vel.y = 0
		vel.y += WALL_SLIDE* delta
		is_wall_sliding = true
	else:
		vel.y += GRAVITY * delta
		is_wall_sliding = false
		
	if is_on_floor():
		# Momentum storage
		prior_x_vel = inputXVel
		# sprite direction
		if vel.x < 0:
			sprite.flip_h = true
		elif vel.x > 0:
			sprite.flip_h = false
	else:
		# Provide player with limited control in the air
		prior_x_vel = clamp((prior_x_vel + (inputXVel * in_air_speed_modifier)), -1, 1)
		inputXVel = prior_x_vel
		
	# applying the velocity
	vel.x = lerp(vel.x, inputXVel * speed, accel)
	vel = move_and_slide(vel, Vector2.UP)
	
	
