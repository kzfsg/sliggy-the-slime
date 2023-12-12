extends Node2D

@export var block_scene: PackedScene

## Called when the node enters the scene tree for the first time.
#func _ready():
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass

func _on_player_hit(pos):
	print('on player hit', pos)
	var block = block_scene.instantiate()
	block.position = pos
	call_deferred("add_child", block)
	
