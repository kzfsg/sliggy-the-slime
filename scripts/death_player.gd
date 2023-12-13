extends AnimatedSprite2D

#signal death_player_finished(pos)

@export var block_scene: PackedScene
@onready var main = $".."
@onready var player = $"../player"

func spawn_block(pos):
	var block = block_scene.instantiate()
	block.position = pos
	#call_deferred("add_child", block)
	main.add_child(block)
	

func play_animation(player_pos):
	position = player_pos
	show()
	play()

func _on_animation_looped():
	#emit_signal("death_player_finished",position)
	player.respawn()
	spawn_block(position)
	hide()
	stop()
