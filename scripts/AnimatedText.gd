extends Node2D

var showed = false

func _ready():
	get_node("Dialogue/Label").visible = false
	print("text hidden")
	
func _on_area_2d_body_entered(body):
	print("text played")
	
	if body is Player:
		get_node("Dialogue/Label").visible = true
		$"Dialogue/AnimationPlayer".play("show")


 
