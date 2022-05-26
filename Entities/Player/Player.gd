extends KinematicBody2D

export var speed: int = 500
export var sprint_speed: int = 900
export var in_air_speed_modifier: float = 0.02
export var accel: float = 0.25

# Sprite constants 
const ARM_RIGHT_Y_STAND = -133
const ARM_LEFT_Y_STAND = -137
const ARM_RIGHT_Y_SLIDE = 10
const ARM_LEFT_Y_SLIDE = 5

# Movement constants
const JUMP_FORCE: int = -600
const GRAVITY: int = 1200
const WALL_SLIDE: int = 300

# Movement properties
var vel: Vector2 = Vector2()
var prior_x_vel: float
var wall_jump_x_vel: float
var is_wall_sliding: bool = false

# Menu properties
var weapon_wheel = preload("res://Menus/InGameMenus/Weapons/WeaponWheel.tscn")
var is_weapon_wheel_open: bool = false

# Weapon constants
const PISTOL = "pistol"
const SHOTGUN = "shotgun"
const UNARMED = "unarmed"

# Weapon handling
var aval_weapons = [ PISTOL, SHOTGUN, UNARMED ]
var weapon_res_map = {
	PISTOL: "res://Entities/Weapons/Pistol/Pistol.tscn",
	SHOTGUN: "res://Entities/Weapons/Shotgun/Shotgun.tscn",
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
		elif is_touching_wall():
			vel.y = JUMP_FORCE
			prior_x_vel = wall_jump_x_vel
			
	if Input.is_action_pressed("sprint"):
		isSprinting = true
			
	# Firing weapons
	if Input.is_action_just_pressed("fire_left_gun"):
		fire_weapon(left_weapon)
	if Input.is_action_just_pressed("fire_right_gun"):
		fire_weapon(right_weapon)
			
	# Weapon swtiching input
	if Input.is_action_just_pressed("weapon_wheels"):
		is_weapon_wheel_open = !is_weapon_wheel_open
		toggle_weapon_wheel()
	
	if Input.is_action_just_pressed("equip_pistols"):
		switch_both_weapons(PISTOL)
		
	if Input.is_action_just_pressed("equip_shotguns"):
		switch_both_weapons(SHOTGUN)
		
	if Input.is_action_just_pressed("unequip_weapons"):
		switch_both_weapons(UNARMED)
		
			
	# gravity
	if is_touching_wall() and !is_on_floor():
		if !is_wall_sliding:
			# Cancel vertical velocity when player initially collides with a wall
			vel.y = 0
			wall_jump_x_vel = -prior_x_vel
			prior_x_vel = 0
		vel.y += (WALL_SLIDE * delta)
		is_wall_sliding = true
	else:
		vel.y += GRAVITY * delta
		is_wall_sliding = false
		
	if is_on_floor():
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
	
# Region: Movement handling ----------------------------------------------------

###
# Get if the player is touching a wall
# Note: Using raycasts instead of "is_on_wall()" as it is much more reliable
###
func is_touching_wall() -> bool:
	return $"Wall-Collision/LeftWall".is_colliding() or $"Wall-Collision/RightWall".is_colliding()

# Region: Sprite handling ------------------------------------------------------
###
# Determine which direction the sprites should be facing
###
func handle_sprite_direction() -> void:
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
func flip_sprites(flip: bool) -> void:
	sprite.flip_h = flip
	if left_weapon != null:
		left_weapon.get_node("AnimatedSprite").flip_v = flip
	if right_weapon != null:
		right_weapon.get_node("AnimatedSprite").flip_v = flip

###
# Alter the z-index properties of the left and right arm
###
func set_arm_z_index(leftIndex: int, rightIndex: int) -> void:
	$"AnimatedSprite/Arm-Left".z_index = leftIndex
	$"AnimatedSprite/Arm-Right".z_index = rightIndex
	
# End Region
# Region: Weapon Handling ------------------------------------------------------

###
# Toggle the weapon wheel
###
func toggle_weapon_wheel() -> void:
	if !is_weapon_wheel_open:
		var menu = weapon_wheel.instance()
		add_child(menu)
	elif $WeaponWheel != null:
		$WeaponWheel.queue_free()
###
# Handle firing a weapon
###
func fire_weapon(weapon) -> void:
	if weapon == null or !weapon.has_method("fire") or weapon.is_firing:
		return
		
	weapon.is_firing = true
	weapon.fire()
	if "fire_rate" in weapon:
		yield(get_tree().create_timer(weapon.fire_rate), "timeout")
	if is_instance_valid(weapon):
		weapon.is_firing = false

###
# Switch both left and right weapons
###
func switch_both_weapons(weaponName: String) -> void:
	switch_weapon(weaponName, true)
	switch_weapon(weaponName, false)

###
# Switch a weapon for a given hand
###
func switch_weapon(weaponName: String, isLeft: bool) -> void:
	unequip_weapon(isLeft)
	equip_weapon(weaponName, isLeft)

###
# Equip a weapon for a given hand. Assumes currently none equiped
###
func equip_weapon(weaponName: String, isLeft: bool) -> void:
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
func unequip_weapon(isLeft: bool) -> void:
	if (isLeft and left_weapon == null) or (!isLeft and right_weapon == null):
		return
		
	if isLeft:
		left_weapon.queue_free()
		left_weapon = null
	else:
		right_weapon.queue_free()
		right_weapon = null

# End Region
