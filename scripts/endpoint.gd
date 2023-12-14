extends Area2D

func _on_body_entered(body):
	print('entered')
	if body.is_in_group("player"):
		var curr_scene_path = get_tree().current_scene.scene_file_path
		var path_prefix = "".join(curr_scene_path.split('_').slice(0,-1)) + "_"
		var path_suffix = "." + curr_scene_path.split('.')[-1]
		var next_no = curr_scene_path.to_int() + 1
		var new_scene_path = "%s%s%s" % [path_prefix, next_no, path_suffix]
		get_tree().call_deferred("change_scene_to_file", new_scene_path)
