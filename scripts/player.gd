extends CharacterBody2D

@onready var ap = $AnimationPlayer
@onready var sprite = $Sprite2D

const SPEED = 150.0
const JUMP_VELOCITY = -400.0
const JUMP_BUFFER_TIME = 15
const COYOTE_TIME = 15

var jump_buffer_counter : int = 0
var coyote_counter : int = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
		# Coyote Time
	if is_on_floor():
		coyote_counter = COYOTE_TIME
	
	if not is_on_floor():
		if coyote_counter > 0:
			coyote_counter -= 1

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
		
	# Jump Buffer Input
	if Input.is_action_just_pressed("ui_accept"):
		jump_buffer_counter = JUMP_BUFFER_TIME
		
	if jump_buffer_counter > 0:
		jump_buffer_counter -= 1
		
	if jump_buffer_counter > 0 and coyote_counter > 0:
		velocity.y = JUMP_VELOCITY
		jump_buffer_counter = 0
		coyote_counter = 0
	
	# Fast Fall
	if Input.is_action_just_released("ui_accept"):
		if velocity.y < 0:
			velocity.y += 100
			

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if direction != 0:
		sprite.flip_h = (direction == -1)

	move_and_slide()
	
	update_animations(direction)
	
func update_animations(direction):
	if is_on_floor():
		if direction == 0:
			ap.play("idle")
		else:
			ap.play("run")
	else:
		if velocity.y < 0:
			ap.play("jump")
		elif velocity.y > 0:
			ap.play("fall")


