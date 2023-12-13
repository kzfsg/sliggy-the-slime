extends Node

#@export var block_scene: PackedScene

#func _on_death_player_death_player_finished(pos):
	#var block = block_scene.instantiate()
	#block.position = pos
	#call_deferred("add_child", block)

func _on_clear_all_pressed():
	get_tree().call_group("blocks","queue_free")
