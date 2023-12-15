extends TileMap

const OPENING_SPEED = 40

@onready var tomb_opening_audio = $AudioStreamPlayer

var opening = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if opening:
		position.y -= delta * OPENING_SPEED
	if position.y < -160:
		opening = false

func trigger():
	tomb_opening_audio.play()
	opening = true
