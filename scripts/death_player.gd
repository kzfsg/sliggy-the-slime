extends AnimatedSprite2D

signal death_player_finished(pos)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_tile_map_player_hit_damage(player_pos):
	position = player_pos
	show()
	play()

func _on_animation_looped():
	emit_signal("death_player_finished",position)
	hide()
	stop()


func _on_animation_finished():
	print('animation finished')
