extends KinematicBody2D

export var speed: int = 500
export var inAirSpeed: int = 200

# Movement constants
const JUMP_FORCE: int = -600
const GRAVITY: int = 1200
const WALL_SLIDE: int = 300

# Movement properties
var vel: Vector2 = Vector2()
var priorXVel: int
var isWallSliding: bool = false

onready var sprite = $AnimatedSprite


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	vel.x = 0
	
	# movement inputs
	if Input.is_action_pressed("move_left"):
		vel.x -= speed
		if !is_on_floor():
			vel.x -= clamp(inAirSpeed, -speed, inAirSpeed)
	if Input.is_action_pressed("move_right"):
		vel.x += speed
		if !is_on_floor():
			vel.x += clamp(inAirSpeed, inAirSpeed, speed)
		
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
		
	# Momentum storage
	if is_on_floor():
		priorXVel = vel.x
	elif vel.x == 0:
		vel.x = priorXVel

	# sprite direction
	if vel.x < 0:
		sprite.flip_h = true
	elif vel.x > 0:
		sprite.flip_h = false
		
	# applying the velocity
	vel = move_and_slide(vel, Vector2.UP)
	
	
