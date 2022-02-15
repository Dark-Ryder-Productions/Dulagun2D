extends KinematicBody2D

export var speed: int = 500
export var sprint_speed: int = 900
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
const UNARMED = "unarmed"

# Weapon handling
var aval_weapons = [ PISTOL, UNARMED ]
var weapon_res_map = {
	PISTOL: "res://Entities/Weapons/Pistol/Pistol.tscn",
	UNARMED: "res://Entities/Weapons/Unarmed/Unarmed.tscn"
}
var left_weapon = null
var right_weapon = null

onready var sprite = $AnimatedSprite

func _ready():
	switch_both_weapons(UNARMED)

func _physics_process(delta):
	var inputXVel = 0
	var isSprinting: bool = false
	
	# Movement inputs
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
			
	if Input.is_action_pressed("sprint"):
		isSprinting = true
		
	if Input.is_action_just_pressed("slide"):
		pass # Add this later
			
	# Firing weapons
	if Input.is_action_just_pressed("fire_left_gun"):
		if left_weapon != null:
			left_weapon.fire()
	if Input.is_action_just_pressed("fire_right_gun"):
		if right_weapon != null:
			right_weapon.fire()
			
	# Weapon swtiching input
	if Input.is_action_just_pressed("equip_pistols"):
		switch_both_weapons(PISTOL)
		
	if Input.is_action_just_pressed("unequip_weapons"):
		switch_both_weapons(UNARMED)
			
	# gravity
	if is_on_wall() and !is_on_floor():
		if !is_wall_sliding:
			# Cancel vertical velocity when player initially collides with a wall
			vel.y = 0
		vel.y += (WALL_SLIDE * delta)
		is_wall_sliding = true
	else:
		vel.y += GRAVITY * delta
		is_wall_sliding = false
		
	if is_on_floor():
		# Momentum storage
		prior_x_vel = inputXVel
	else:
		# Provide player with limited control in the air
		prior_x_vel = clamp((prior_x_vel + (inputXVel * in_air_speed_modifier)), -1, 1)
		inputXVel = prior_x_vel
		
	handle_sprite_direction()
	
	# applying the velocity
	var moveSpeed = sprint_speed if isSprinting else speed
	vel.x = lerp(vel.x, inputXVel * moveSpeed, accel)
	vel = move_and_slide(vel, Vector2.UP)
	
# Region: Sprite handling ------------------------------------------------------
###
# Determine which direction the sprites should be facing
###
func handle_sprite_direction():
	# sprite direction
	if get_global_mouse_position().x < global_position.x:
		flip_sprites(true)
		set_arm_z_index(1, -1)
	else:
		flip_sprites(false)
		set_arm_z_index(-1, 1)

###
# Flip the player's main sprite horizontally and the weapon sprites vertically
###
func flip_sprites(flip: bool):
	sprite.flip_h = flip
	if left_weapon != null:
		left_weapon.get_node("AnimatedSprite").flip_v = flip
	if right_weapon != null:
		right_weapon.get_node("AnimatedSprite").flip_v = flip

###
# Alter the z-index properties of the left and right arm
###
func set_arm_z_index(leftIndex: int, rightIndex: int):
	$"AnimatedSprite/Arm-Left".z_index = leftIndex
	$"AnimatedSprite/Arm-Right".z_index = rightIndex

# End Region
# Region: Weapon Handling ------------------------------------------------------

###
# Switch both left and right weapons
###
func switch_both_weapons(weaponName: String):
	switch_weapon(weaponName, true)
	switch_weapon(weaponName, false)

###
# Switch a weapon for a given hand
###
func switch_weapon(weaponName: String, isLeft: bool):
	unequip_weapon(isLeft)
	equip_weapon(weaponName, isLeft)

###
# Equip a weapon for a given hand. Assumes currently none equiped
###
func equip_weapon(weaponName: String, isLeft: bool):
	if (isLeft and left_weapon != null and left_weapon.TYPE == weaponName) or (!isLeft and right_weapon != null and right_weapon.TYPE == weaponName):
		return
	
	var scene = load(weapon_res_map[weaponName])
	var weapon = scene.instance()
	
	weapon.is_left = isLeft
	if isLeft:
		get_node("AnimatedSprite/Arm-Left").add_child(weapon)
		left_weapon = weapon
	else: 
		get_node("AnimatedSprite/Arm-Right").add_child(weapon)
		right_weapon = weapon
	
###
# Unequip a current weapon for a given hand
###
func unequip_weapon(isLeft: bool):
	if (isLeft and left_weapon == null) or (!isLeft and right_weapon == null):
		return
		
	if isLeft:
		left_weapon.queue_free()
		left_weapon = null
	else:
		right_weapon.queue_free()
		right_weapon = null

# End Region
