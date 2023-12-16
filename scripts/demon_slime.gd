extends AnimatedSprite2D

@export var text_box_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(0).timeout
	global_position = Vector2(100, 185)
	play('jump')
	await get_tree().create_timer(1).timeout
	global_position = Vector2(505, 270)
	var text_box = text_box_scene.instantiate()
	text_box.position = Vector2(505, 450)
	text_box.text = "RWAAARRRRHHH"
	get_tree().root.add_child(text_box)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
