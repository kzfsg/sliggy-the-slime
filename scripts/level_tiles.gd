extends TileMap

signal broadcast_tile_pos(pos)
signal player_hit_damage(player_pos)
@onready var death_player = $"../death_player"
@onready var player = $"../player"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func on_player_collision(collision, player_pos):	
	var collider = collision.get_collider()
	if collider is TileMap:
		var tile_map = collider
		var tile_local_pos = tile_map.get_coords_for_body_rid(collision.get_collider_rid())
		var tile_map_pos = tile_map.map_to_local(tile_local_pos)
		var tile_id = collider.get_cell_source_id(0, tile_local_pos)
		if (tile_id == 1):
			#emit_signal("player_hit_damage", player_pos)
			death_player.play_animation(player_pos)
			player.die()
