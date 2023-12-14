extends Node2D

@onready var old = $old
@onready var new = $new
@onready var animation_player = $AnimationPlayer

func play(new_val):
	show()
	old.text = str(new_val+1)
	new.text = str(new_val)
	animation_player.play("health_drop")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "health_drop":
		hide()
