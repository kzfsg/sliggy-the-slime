extends CharacterBody2D

class_name Hazard2

const SPEED = 100.0
var isUp = false
@onready var animated_sprite_2d = $AnimatedSprite2D

func _physics_process(delta):
	var direction = -1 if isUp else 1
	velocity.y = direction * SPEED
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision:
			#var collider = collision.get_collider()
			#if collider is TileMap or collider is Block:
			isUp = true if collision.get_normal().y < 0 else false
	
	move_and_slide()


func _on_area_2d_body_entered(body):
	if body is Block:
		isUp = !isUp
