extends Node2D


func _ready():
	get_node("Instructions 1/Move/LeftArrow").visible = false
	get_node("Instructions 1/Move/RightArrow").visible = false
	get_node("Instructions 1/Move/MoveText").visible = false
	get_node("Instructions 1/Move/MoveTextBack").visible = false
	get_node("Instructions 1/Jump/JumpText").visible = false
	get_node("Instructions 1/Jump/JumpTextBack").visible = false
	get_node("Instructions 1/Death/DeathText").visible = false
	get_node("Instructions 1/Death/DeathTextBack").visible = false
	get_node("Instructions 1/Death/IsText").visible = false
	get_node("Instructions 1/Death/IsTextBack").visible = false
	get_node("Instructions 1/Death/TempTextBack").visible = false
	get_node("Instructions 1/Death/TempText").visible = false
	
	get_node("Main Menu/menu_tiles").visible = true
	
	
func _on_play_pressed():
	get_node("Main Menu").queue_free()
	get_node("player").global_position = Vector2(76, 527)
	# Handle Camera2D
	var camera = get_node("player/Camera2D")
	camera.zoom = Vector2(1.5,1.5)
	camera.enabled = true
	
	
	# Handle Instruction Visiblitiy
	
	get_node("Instructions 1/Move/LeftArrow").visible = true
	get_node("Instructions 1/Move/RightArrow").visible = true
	get_node("Instructions 1/Move/MoveText").visible = true
	get_node("Instructions 1/Move/MoveTextBack").visible = true
	get_node("Instructions 1/Jump/JumpText").visible = true
	get_node("Instructions 1/Jump/JumpTextBack").visible = true
	get_node("Instructions 1/Death/DeathText").visible = true
	get_node("Instructions 1/Death/DeathTextBack").visible = true
	get_node("Instructions 1/Death/IsText").visible = true
	get_node("Instructions 1/Death/IsTextBack").visible = true
	get_node("Instructions 1/Death/TempTextBack").visible = true
	get_node("Instructions 1/Death/TempText").visible = true
	
	get_node("Main Menu/menu_tiles").visible = false
func _on_quit_pressed():
	get_tree().quit()
