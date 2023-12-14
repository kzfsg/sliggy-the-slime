extends CharacterBody2D

class_name Player

const SPEED = 300.
const JUMP_VELOCITY = -600.0
const JUMP_EXTEND_DELTA = 0.15
const COYOTE_TIME = 8

@onready var collision_shape_2d = $CollisionShape2D
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var hazard_tiles = $"../hazard_tiles"
@onready var death_player = $"../death_player"
@onready var spawnpoint = $"../spawnpoint"

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_left = false
var jump_extend_counter = 0
var coyote_counter : int = 0
var is_dead = false
var is_respawning = false
var should_show_after_death = false

func jump(delta):
	jump_extend_counter += delta
	velocity.y = JUMP_VELOCITY

func clear():
	get_tree().call_group("blocks", "queue_free")

func _process(_delta):
	#emit_signal("player_pos_signal", position)
	if Input.is_action_just_pressed("clear"):
		clear()
	if Input.is_action_just_pressed("respawn"):
		respawn()

func _physics_process(delta):
	print(animated_sprite_2d.animation)
	var cannot_move = is_dead or is_respawning
	if not is_respawning:
		should_show_after_death = false
	#animations
	if (velocity.x > 1 || velocity.x < -1):
		animated_sprite_2d.animation = "running"
	elif is_respawning:
		if should_show_after_death:
			show()
			should_show_after_death = false
			collision_shape_2d.disabled = false
		else:
			should_show_after_death = true
		animated_sprite_2d.animation = "respawn"
	else:
		animated_sprite_2d.animation = "idle"
		
	
	if not is_on_floor() and not cannot_move and Input.is_action_just_pressed("jump") and coyote_counter > 0:
			jump(delta)
	
	if is_on_floor():
		# Coyote Time
		coyote_counter = COYOTE_TIME
		# Handle jump.
		if not cannot_move and Input.is_action_just_pressed("jump"):
			jump(delta)
	else:
		animated_sprite_2d.animation = "falling"
		# Coyote Time
		if coyote_counter > 0:
			coyote_counter -= 1
		#handle jump extend
		if Input.is_action_pressed("jump") and jump_extend_counter > 0 and jump_extend_counter < JUMP_EXTEND_DELTA:
			jump_extend_counter += delta	
		else:
			jump_extend_counter = 0
			# Add the gravity.
			if not is_dead:
				velocity.y += gravity * delta
				animated_sprite_2d.animation = "falling"

	if not cannot_move:
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
			var collider = collision.get_collider()
			if collider is HazardTile or collider is Hazard:
				die()

func stop_moving():
	velocity = Vector2(0,0)

func die():
	#if is_dead: return
	#collision_shape_2d.set_deferred("disabled",true)
	collision_shape_2d.disabled = true
	stop_moving()
	is_dead = true
	hide()
	death_player.play_animation(position)
	#position = spawnpoint.position

func respawn():
	stop_moving()
	position = spawnpoint.position
	#collision_shape_2d.disabled = false
	is_dead = false
	is_respawning = true

func _on_respawn_pressed():
	respawn()

func _on_animated_sprite_2d_animation_looped():
	if is_respawning:
		is_respawning = false
		animated_sprite_2d.animation
