extends KinematicBody2D


# Movement constants
export var speed: int = 500
const JUMP_FORCE: int = 600
const GRAVITY: int = 900

# Movement properties
var vel: Vector2 = Vector2()
var priorXVel: int

onready var sprite = $AnimatedSprite


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	handle_input(delta)
	handle_physics(delta)

func handle_input(delta):
	priorXVel = vel.x
	vel.x = 0
	
	# movement inputs
	if Input.is_action_pressed("move_left"):
		vel.x -= speed
	if Input.is_action_pressed("move_right"):
		vel.x += speed
		
	# jump input
	if Input.is_action_pressed("jump"):
		if is_on_floor():
			vel.y -= JUMP_FORCE
		if is_on_wall():
			#wall jump
			pass
	
func handle_physics(delta):
	# gravity
	vel.y += GRAVITY * delta
		
	if !is_on_floor():
		vel.x = priorXVel

	# sprite direction
	if vel.x < 0:
		sprite.flip_h = true
	elif vel.x > 0:
		sprite.flip_h = false
		
	# applying the velocity
	vel = move_and_slide(vel, Vector2.UP)
	
