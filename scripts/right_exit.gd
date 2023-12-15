extends TileMap

const OPENING_SPEED = 40

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
	opening = true
