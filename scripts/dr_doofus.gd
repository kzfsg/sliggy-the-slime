extends CharacterBody2D

const SPEED = 100
const DASH_SPEED = 250
const DASH_DIST = 200

@onready var player = $"../player"
@onready var ani_sprite = $AnimatedSprite2D

var is_left = true
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

enum state {walk, dash, freeze}
var curr_state = state.walk
var dash_direction = 1

func _physics_process(delta):
	var player_pos = player.position
	var player_x = player_pos.x
	var player_dist_x = abs(player_x - position.x)
	velocity.y += gravity * delta
	
	#set direction
	if player_x < position.x:
		is_left = true
	else:
		is_left = false
	var direction = (-1 if is_left else 1)
	
	#match state
	match curr_state:
		state.walk:
			#position.x += direction * SPEED * delta
			velocity.x = direction * SPEED
			ani_sprite.play("walk")
			ani_sprite.flip_h = is_left
			#set state
			#print("%s %s"%[player_dist_x,abs(player_dist_x - DASH_DIST)])
			if abs(player_dist_x - DASH_DIST) < 50:
				trigger_dash(direction)
			else:
				curr_state = state.walk
		state.dash:
			#position.x += dash_direction * DASH_SPEED * delta
			velocity.x = dash_direction * DASH_SPEED
		state.freeze:
			velocity.x = 0
			#ani_sprite.stop()
			
	move_and_slide()
	#
	#for i in get_slide_collision_count():
		#var collision = get_slide_collision(i)
		#if collision:
			#var collider = collision.get_collider()
			#if collider is Block:
				#trigger_attack(collider)


func trigger_dash(direction):
	dash_direction = direction
	curr_state = state.freeze
	ani_sprite.play("aggro")
	await ani_sprite.animation_finished
	#await get_tree().create_timer(0.8).timeout
	curr_state = state.dash
	ani_sprite.play("dash")
	await ani_sprite.animation_finished
	curr_state = state.freeze
	ani_sprite.play("rest")
	await ani_sprite.animation_finished
	#await get_tree().create_timer(0.8).timeout
	curr_state = state.walk

func trigger_attack(collider):
	curr_state = state.freeze
	ani_sprite.play("attack")
	await ani_sprite.animation_finished
	collider.queue_free()
	curr_state = state.walk

func _on_area_2d_body_entered(body):
	if body is Player:
		player.die()
	if body is Block:
		if curr_state == state.dash:
			body.queue_free()
		elif curr_state == state.walk:
			trigger_attack(body)
