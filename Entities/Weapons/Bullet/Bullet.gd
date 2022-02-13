extends Area2D

export var speed = 1400
export var damage = 20

func _ready():
	pass 

func _physics_process(delta):
	position += transform.x * speed * delta
	
###
# Apply damage and remove bullet when it collides with another body
###
func _on_Bullet_body_entered(body):
	if body.has_method("apply_damage"):
		body.apply_damage(damage)
	queue_free()

###
# Remove bullet when it leaves the screen
###
func _on_screen_exited():
	queue_free()
