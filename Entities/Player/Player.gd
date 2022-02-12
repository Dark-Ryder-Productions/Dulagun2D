extends KinematicBody2D

export var speed: int = 500
export var inAirSpeedModifier: float = 0.02
export var accel: float = 0.25
export var friction: float = 0.1

# Movement constants
const JUMP_FORCE: int = -600
const GRAVITY: int = 1200
const WALL_SLIDE: int = 300

# Movement properties
var vel: Vector2 = Vector2()
var priorXVel: float
var isWallSliding: bool = false

onready var sprite = $AnimatedSprite


func _ready():
	pass 

func _physics_process(delta):
	vel.x = 0
	
	# movement inputs
	if Input.is_action_pressed("move_left"):
		vel.x -= 1
	if Input.is_action_pressed("move_right"):
		vel.x += 1
		
	# jump input
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			vel.y = JUMP_FORCE
		elif is_on_wall():
			vel.y = JUMP_FORCE
			priorXVel = -priorXVel
			
	# gravity
	if is_on_wall():
		if !isWallSliding:
			# Cancel vertical velocity when player initially collides with a wall
			vel.y = 0
		vel.y += WALL_SLIDE* delta
		isWallSliding = true
	else:
		vel.y += GRAVITY * delta
		isWallSliding = false
		
	if is_on_floor():
		# Momentum storage
		priorXVel = vel.x
		# sprite direction
		if vel.x < 0:
			sprite.flip_h = true
		elif vel.x > 0:
			sprite.flip_h = false
	else:
		# Provide player with limited control in the air
		priorXVel = clamp((priorXVel + (vel.x * inAirSpeedModifier)), -1, 1)
		vel.x = priorXVel

	
		
	# applying the velocity
	vel.x *= speed
	vel = move_and_slide(vel, Vector2.UP)
	
	
