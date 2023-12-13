extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if body.is_in_group("player"):
		var curr_scene_path = get_tree().current_scene.scene_file_path
		var path_prefix = "".join(curr_scene_path.split('_').slice(0,-1)) + "_"
		var path_suffix = "." + curr_scene_path.split('.')[-1]
		var next_no = curr_scene_path.to_int() + 1
		var new_scene_path = "%s%s%s" % [path_prefix, next_no, path_suffix]
		get_tree().change_scene_to_file(new_scene_path)
		
