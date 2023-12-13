extends CharacterBody2D

signal collision(collision, player_pos)
signal player_pos_signal(player_pos)
signal broadcast_player_collision_pos(pos)
#signal player_death(pos)

const SPEED = 300.
const JUMP_VELOCITY = -600.0
const JUMP_EXTEND_DELTA = 0.15

@onready var collision_shape_2d = $CollisionShape2D
@onready var animated_sprite_2d = $AnimatedSprite2D
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_left = false
var jump_extend_counter = 0
var is_respawning = false
var should_show_after_death = false

func _process(_delta):
	emit_signal("player_pos_signal", position)

func _physics_process(delta):
	if not is_respawning:
		should_show_after_death = false
	#animations
	if (velocity.x > 1 || velocity.x < -1):
		animated_sprite_2d.animation = "running"
	elif is_respawning:
		if should_show_after_death:
			show()
			should_show_after_death = false
		else:
			should_show_after_death = true
		animated_sprite_2d.animation = "respawn"
	else:
		animated_sprite_2d.animation = "idle"
	
	if is_on_floor():
		# Handle jump.
		if not is_respawning and Input.is_action_just_pressed("jump"):
			jump_extend_counter += delta
			velocity.y = JUMP_VELOCITY
	else:
		#handle jump extend
		if Input.is_action_pressed("jump") and jump_extend_counter > 0 and jump_extend_counter < JUMP_EXTEND_DELTA:
			jump_extend_counter += delta	
		else:
			jump_extend_counter = 0
			# Add the gravity.
			velocity.y += gravity * delta
			animated_sprite_2d.animation = "jumping"

	if not is_respawning:
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction = Input.get_axis("left", "right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, 40)

	move_and_slide()
	
	if velocity.x < 0:
		is_left = true
	elif velocity.x > 0:
		is_left = false
		
	animated_sprite_2d.flip_h = is_left
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision:
			emit_signal("collision", collision, position)

func _on_tile_map_player_hit_damage(pos):
	collision_shape_2d.set_deferred("disabled",true)
	hide()

func respawn():
	collision_shape_2d.disabled = false
	is_respawning = true
	position = Vector2(30,490)

func _on_death_player_death_player_finished(pos):
	respawn()
	#show()

func _on_respawn_pressed():
	respawn()

func _on_animated_sprite_2d_animation_looped():
	if is_respawning:
		is_respawning = false
		animated_sprite_2d.animation
