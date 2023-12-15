extends Node2D

func set_instruction_items_visibility(visible):
	for group in get_node("Instructions 1").get_children():
		for item in group.get_children():
			item.visible = visible

func _ready():
	set_instruction_items_visibility(false)

func _on_play_pressed():
	get_node("Main Menu").queue_free()
	get_node("player").global_position = Vector2(76, 527)
	# Handle Camera2D
	var camera = get_node("player/Camera2D")
	camera.zoom = Vector2(1.5,1.5)
	camera.enabled = true
	
	
	# Handle Instruction Visiblitiy
	set_instruction_items_visibility(true)
	
func _on_quit_pressed():
	get_tree().quit()
