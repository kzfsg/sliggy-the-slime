extends CharacterBody2D

class_name Hazard

const SPEED = 200.0
var isLeft = false
@onready var animated_sprite_2d = $AnimatedSprite2D

func _physics_process(_delta):
	var direction = -1 if isLeft else 1
	velocity.x = direction * SPEED
	
	animated_sprite_2d.flip_h = isLeft
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision:
			#var collider = collision.get_collider()
			#if collider is TileMap:
			isLeft = true if collision.get_normal().x < 0 else false
	
	move_and_slide()


func _on_area_2d_body_entered(body):
	if body is Block:
		isLeft = !isLeft
