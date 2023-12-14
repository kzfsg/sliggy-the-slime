extends Area2D

@onready var spawnpoint = $"../spawnpoint"
@onready var color_rect = $ColorRect

func _on_body_entered(body):
	if body.is_in_group("player"):
		spawnpoint.position = position
		color_rect.visible = false
