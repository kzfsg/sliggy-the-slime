extends CharacterBody2D

const SPEED = 75
const FOLLOW_SPEED = 125
const DASH_SPEED = 250
const DASH_DIST = 200

@onready var player = $"../player"
@onready var ani_sprite = $AnimatedSprite2D
@onready var dash_sound = $dash
@onready var alert_sound = $alert

var is_left = true
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
enum state {walk, dash, freeze, follow, dead}
var curr_state = state.freeze
var dash_direction = 1
@export var hp = 3

var first_aggro = false

func _ready():
	await get_tree().create_timer(0.8).timeout
	ani_sprite.play('aggro')
	alert_sound.play()
	await get_tree().create_timer(3).timeout
	curr_state = state.follow

func _physics_process(delta):
	var player_pos = player.position
	var player_x = player_pos.x
	var player_dist_x = abs(player_x - position.x)
	velocity.y += gravity * delta
	
	var direction = (-1 if is_left else 1)
	
	#follow or walk
	if curr_state in [state.follow, state.walk]:
		curr_state = state.follow
	
	#match state
	match curr_state:
		state.follow:
			#set direction
			if player_x < position.x:
				is_left = true
			else:
				is_left = false
			#if player_x < position.x - 5:
				#is_left = true
			#elif player_x > position.x + 5:
				#is_left = false
			ani_sprite.flip_h = is_left
			ani_sprite.play("walk")
			if abs(player_x - position.x) > 5:
				velocity.x = direction * SPEED
			else:
				velocity.x = 0
		state.walk:
			ani_sprite.flip_h = is_left
			ani_sprite.play("walk")
			velocity.x = direction * SPEED
		state.dash:
			#position.x += dash_direction * DASH_SPEED * delta
			velocity.x = dash_direction * DASH_SPEED
		state.freeze:
			#ani_sprite.stop()
			velocity.x = 0
		state.dead:
			velocity.x = 0
			
	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision:
			var collider = collision.get_collider()
			if collider is TileMap:
				var normal = collision.get_normal()
				if normal.y == 0:
					is_left = true if normal.x < 0 else false


func trigger_dash(direction):
	dash_direction = direction
	curr_state = state.freeze
	ani_sprite.play("aggro")
	await ani_sprite.animation_finished
	if curr_state == state.dead: return
	dash_sound.play()
	curr_state = state.dash
	ani_sprite.play("dash")
	await ani_sprite.animation_finished
	if curr_state == state.dead: return
	curr_state = state.freeze
	ani_sprite.play("rest")
	await ani_sprite.animation_finished
	if curr_state == state.dead: return
	curr_state = state.walk

func trigger_attack(collider):
	curr_state = state.freeze
	ani_sprite.play("attack")
	await ani_sprite.animation_finished
	if curr_state == state.dead: return
	collider.queue_free()
	curr_state = state.walk
	
func trigger_hurt():
	print('trgger_hurt, prev hp: %s'%hp)
	hp -= 1
	print('new hp: %s'%hp)
	if hp == 0:
		print('change state to dead')
		curr_state = state.dead
	else:
		curr_state = state.freeze
	ani_sprite.play("hurt")
	print('play hurt')
	await ani_sprite.animation_finished
	print('finish playing hurt')
	if hp == 0:
		print('inside hp === 0')
		trigger_death()
		return
	ani_sprite.play("rest")
	await ani_sprite.animation_finished
	curr_state = state.walk
	
func trigger_death():
	DialogManager._advance_dialog()
	ani_sprite.play('death')
	await ani_sprite.animation_finished
	queue_free()
	$"../right_exit".trigger()

func _on_area_2d_body_entered(body):
	if body is Player and curr_state != state.dead:
		player.die()
	if body is Block:
		if body.position.y < position.y - 30:
			trigger_hurt()
			DialogManager._advance_dialog()
			body.queue_free()
		elif curr_state == state.dash:
			body.queue_free()
		elif curr_state == state.walk or curr_state == state.follow:
			trigger_attack(body)
