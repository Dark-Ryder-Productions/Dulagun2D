extends KinematicBody2D


# Movement constants
const SPEED: int = 500
const JUMP_FORCE: int = 600
const GRAVITY: int = 800

# Movement properties
var vel: Vector2 = Vector2()
var isOnGround: bool = false

onready var sprite = $AnimatedSprite


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	# reset horizontal velocity
	vel.x = 0
	# movement inputs
	if Input.is_action_pressed("move_left"):
		vel.x -= SPEED
	if Input.is_action_pressed("move_right"):
		vel.x += SPEED
		
	# applying the velocity
	vel = move_and_slide(vel, Vector2.UP)
	
	
	# gravity
	vel.y += GRAVITY * delta
	# jump input
	if Input.is_action_pressed("jump") and is_on_floor():
		vel.y -= JUMP_FORCE
		
	# sprite direction
	if vel.x < 0:
		sprite.flip_h = true
	elif vel.x > 0:
		sprite.flip_h = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
