extends CharacterBody2D

class_name Player

const SPEED = 300.
const JUMP_VELOCITY = -600.0
const JUMP_EXTEND_DELTA = 0.15
const COYOTE_TIME = 8
const PUSH = 200
const RUNNING_AUDIO_STOP_DELAY = 0.3

@onready var collision_shape_2d = $CollisionShape2D
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var death_player = $"../death_player"
@onready var spawnpoint = $"../spawnpoint"
@onready var lives_indicator = $lives_indicator
@onready var jump_audio_1 = $audio/jump_1
@onready var jump_audio_2 = $audio/jump_2
@onready var running_audio = $audio/running
@onready var landing_audio = $audio/landing
@onready var hp_label = $"../hud/hp/Label"
@onready var dead_icon = $"../hud/hp/Sprite2D"
@onready var pushing_audio = $audio/pushing
@onready var timer_label = $"../hud/timer"

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_left = false
var jump_extend_counter = 0
var coyote_counter : int = 0
var should_show_after_death = false
@export var total_lives: int
var lives: int
@export var show_vat_spawn: bool = false
@export var limited_lives: bool = true
enum state {idle, running, falling, dead, respawning, spawning, pushing}
var curr_state = state.idle
var running_audio_stop_counter = 0
var prev_velocity: Vector2
@export var count_deaths: bool = true
var deaths = 0
@export var start_timer_here = false
@export var show_timer = true

func jump(delta):
	var jump_audio = [jump_audio_1, jump_audio_2].pick_random()
	jump_audio.play()
	jump_extend_counter += delta
	velocity.y = JUMP_VELOCITY

func clear():
	get_tree().call_group("blocks", "queue_free")

func _ready():
	if start_timer_here:
		PlayerVariables.time_elapsed = 0
	if not count_deaths:
		dead_icon.visible = false
		hp_label.visible = false
	if not show_timer:
		timer_label.visible = false
	if show_vat_spawn:
		curr_state = state.spawning
		animated_sprite_2d.play("spawn")
		await animated_sprite_2d.animation_finished
		curr_state = state.idle
	lives = total_lives

func _process(_delta):
	#if hp_label:
		#hp_label.text = str(lives)
	if count_deaths and hp_label:
		hp_label.text = str(PlayerVariables.deaths)
	if timer_label:
		var time_elapsed = PlayerVariables.time_elapsed
		var time_str = str(snapped(time_elapsed, 0.01))
		var pad = 3 - time_str.split('.')[-1].length()
		for i in range(pad):
			time_str += '0'
		if '.' not in time_str:
			time_str += '.000'
		timer_label.text = time_str
	if curr_state == state.spawning:
		return
	#emit_signal("player_pos_signal", position)
	if Input.is_action_just_pressed("clear"):
		clear()
	if Input.is_action_just_pressed("respawn"):
		respawn()

func _physics_process(delta):
	if curr_state == state.dead: 
		running_audio.stop()
		pushing_audio.stop()
		return
	#print(state.keys()[curr_state])
	prev_velocity = velocity
	move_and_slide()
	var cannot_move = curr_state in [state.dead, state.respawning]
	
	if curr_state != state.respawning:
		should_show_after_death = false
	if curr_state == state.spawning:
		animated_sprite_2d.show()
		collision_shape_2d.disabled = false
		animated_sprite_2d.play("spawn")
		return
		
	if curr_state == state.pushing:
		if not pushing_audio.playing:
			pushing_audio.play()
	else:
		if pushing_audio.playing:
			pushing_audio.stop()
	#animations
	if get_real_velocity().x != 0 and is_on_floor():
		if curr_state == state.pushing:
			animated_sprite_2d.play("push")
		else:
			curr_state = state.running
			animated_sprite_2d.play("running")
	#delay enabling collision to the second frame so it doesn't clip the spawned block
	elif curr_state == state.respawning:
		if should_show_after_death:
			animated_sprite_2d.show()
			should_show_after_death = false
			collision_shape_2d.disabled = false
		else:
			should_show_after_death = true
		animated_sprite_2d.play("respawn")
		return
	elif is_on_floor():
		curr_state = state.idle
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
		#if curr_state != state.dead:
		curr_state = state.falling
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
			if curr_state != state.dead:
				velocity.y += gravity * delta
				animated_sprite_2d.play("falling")

	if not cannot_move:
		var direction = Input.get_axis("left", "right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, 40)

	#move_and_slide()
	
	if velocity.x < 0:
		is_left = true
	elif velocity.x > 0:
		is_left = false
		
	animated_sprite_2d.flip_h = is_left
	
	#sounds
	#print(curr_state)
	if curr_state == state.running:
		if not running_audio.playing:
			running_audio_stop_counter = 0
			running_audio.play()
	else:
		if running_audio.playing:
			running_audio_stop_counter += delta
			if running_audio_stop_counter > RUNNING_AUDIO_STOP_DELAY:
				running_audio.stop()
	
	#pushing = false
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision:
			var collider = collision.get_collider()
			if collider is HazardTile or collider is Hazard or collider is Hazard2:
				print('collider trigger death')
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
				curr_state = state.pushing
				animated_sprite_2d.play("push")
				#collider.apply_central_impulse(force)
				#collider.apply_central_force(force)
	if (prev_velocity - velocity).y > 300:
		landing_audio.play()

func stop_moving():
	velocity = Vector2(0,0)

func die():
	if curr_state == state.dead: return
	curr_state = state.dead
	if count_deaths: 
		PlayerVariables.deaths += 1
	#collision_shape_2d.set_deferred("disabled",true)
	lives -= 1
	collision_shape_2d.set_deferred("disabled",true)
	stop_moving()
	curr_state = state.dead
	animated_sprite_2d.hide()
	if limited_lives:
		lives_indicator.play(lives)
	death_player.play_animation(position)
	#position = spawnpoint.position

func respawn():
	stop_moving()
	position = spawnpoint.position
	#collision_shape_2d.disabled = false
	if lives == 0 and limited_lives:
		lives = total_lives
		clear()
		curr_state = state.spawning
	else:
		curr_state = state.respawning

func _on_respawn_pressed():
	respawn()

func _on_animated_sprite_2d_animation_finished():
	if curr_state in [state.spawning, state.respawning]:
		curr_state = state.idle
