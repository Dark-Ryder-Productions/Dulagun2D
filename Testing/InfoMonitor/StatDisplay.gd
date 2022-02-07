extends MarginContainer

func _physics_process(_delta):
	$HBoxContainer/VBoxContainer/StatFPS.text = "FPS: " + str(Performance.get_monitor(Performance.TIME_FPS))
	$HBoxContainer/VBoxContainer/StatMem.text = "Memory: " + str(round(Performance.get_monitor(Performance.MEMORY_STATIC)/1024/1024)) + " MB"
