extends AnimatedSprite2D

@export var block_scene: PackedScene
@onready var level_holder = $".."
@onready var player = $"../player"
@onready var death_audio = $slime_hitsound

func spawn_block(pos):
	var block = block_scene.instantiate()
	block.position = pos
	level_holder.add_child(block)
	

func play_animation(player_pos):
	death_audio.play()
	position = player_pos
	show()
	play()

func _on_animation_looped():
	spawn_block(position)
	hide()
	stop()
	await get_tree().create_timer(0.5).timeout
	player.respawn()
