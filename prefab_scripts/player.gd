extends Node2D

# refrences
@onready var player_gun_anchor: Node2D = $"."
@onready var player_sprite: Sprite2D = $"../player_sprite"
@onready var player_gun_sprite: Sprite2D = $player_gun_sprite

func _process(delta: float) -> void:
	player_gun_anchor.look_at(get_global_mouse_position())
	if get_global_mouse_position().x < self.position.x:
		player_sprite.flip_h = true
		player_gun_sprite.flip_v = true
	else:
		player_sprite.flip_h = false
		player_gun_sprite.flip_v = false
