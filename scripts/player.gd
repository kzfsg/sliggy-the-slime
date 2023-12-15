extends CharacterBody2D

class_name Player

const SPEED = 300.
const JUMP_VELOCITY = -600.0
const JUMP_EXTEND_DELTA = 0.15
const COYOTE_TIME = 8
const PUSH = 200

@onready var collision_shape_2d = $CollisionShape2D
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var death_player = $"../death_player"
@onready var spawnpoint = $"../spawnpoint"
@onready var lives_indicator = $lives_indicator

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_left = false
var jump_extend_counter = 0
var coyote_counter : int = 0
var is_dead = false
var is_respawning = false
var should_show_after_death = false
var spawning = false
var pushing = false
@export var total_lives: int
var lives: int
@export var show_vat_spawn: bool = false
@export var limited_lives: bool = true

func jump(delta):
	jump_extend_counter += delta
	velocity.y = JUMP_VELOCITY

func clear():
	get_tree().call_group("blocks", "queue_free")

func _ready():
	if show_vat_spawn:
		spawning = true
		animated_sprite_2d.play("spawn")
		await animated_sprite_2d.animation_finished
		spawning = false
	lives = total_lives

func _process(_delta):
	if spawning:
		return
	#emit_signal("player_pos_signal", position)
	if Input.is_action_just_pressed("clear"):
		clear()
	if Input.is_action_just_pressed("respawn"):
		respawn()

func _physics_process(delta):
	var cannot_move = is_dead or is_respawning
	if not is_respawning:
		should_show_after_death = false
	if spawning:
		animated_sprite_2d.show()
		collision_shape_2d.disabled = false
		animated_sprite_2d.play("spawn")
		return
	#animations	
	if get_real_velocity().x != 0 and is_on_floor():
		if pushing:
			animated_sprite_2d.play("push")
		else:
			animated_sprite_2d.play("running")
	#delay enabling collision to the second frame so it doesn't clip the spawned block
	elif is_respawning:
		if should_show_after_death:
			animated_sprite_2d.show()
			should_show_after_death = false
			collision_shape_2d.disabled = false
		else:
			should_show_after_death = true
		animated_sprite_2d.play("respawn")
		return
	elif is_on_floor():
		animated_sprite_2d.play("idle")
	if not is_on_floor() and not cannot_move and Input.is_action_just_pressed("jump") and coyote_counter > 0:
		jump(delta)
	
	if is_on_floor():
		# Coyote Time
		coyote_counter = COYOTE_TIME
		# Handle jump.
		if not cannot_move and Input.is_action_just_pressed("jump"):
			jump(delta)
	else:
		animated_sprite_2d.play("falling")
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
				animated_sprite_2d.play("falling")

	if not cannot_move:
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
	
	pushing = false
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision:
			var collider = collision.get_collider()
			if collider is HazardTile or collider is Hazard:
				die()
			if collider is RigidBody2D:
				var normal = collision.get_normal()
				if normal.y != 0: return
				#var new_v = Vector2(PUSH * (-1 if is_left else 1), 0)
				#print('push @ ' + str(collider)+ str(velocity) + str(new_v))
				var new_x = PUSH * (-1 if is_left else 1)
				collider.linear_velocity.x = new_x
				#print(normal)
				#if normal.x < 1: return
				#var force = -normal * PUSH
				pushing = true
				animated_sprite_2d.play("push")
				#collider.apply_central_impulse(force)
				#collider.apply_central_force(force)

func stop_moving():
	velocity = Vector2(0,0)

func die():
	if is_dead: return
	#collision_shape_2d.set_deferred("disabled",true)
	lives -= 1
	collision_shape_2d.disabled = true
	stop_moving()
	is_dead = true
	animated_sprite_2d.hide()
	if limited_lives:
		lives_indicator.play(lives)
	death_player.play_animation(position)
	#position = spawnpoint.position

func respawn():
	stop_moving()
	position = spawnpoint.position
	#collision_shape_2d.disabled = false
	is_dead = false
	if lives == 0 and limited_lives:
		lives = total_lives
		clear()
		spawning = true
	else:
		is_respawning = true

func _on_respawn_pressed():
	respawn()

func _on_animated_sprite_2d_animation_finished():
	if spawning:
		spawning = false
	if is_respawning:
		is_respawning = false
