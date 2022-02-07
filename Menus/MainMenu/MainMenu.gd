extends CanvasLayer

func _ready():
	pass 

###
# Launch the testing area scene
###
func launchTestingArea():
	get_tree().change_scene("res://Testing/DebugLevels/Test001.tscn")
