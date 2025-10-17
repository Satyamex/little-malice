extends Node2D

# refrences
@onready var player_gun_anchor: Node2D = $"."
#@onready var player_sprite: Sprite2D = $".."
@onready var player_sprite: Sprite2D = $"../player_sprite"
@onready var player_gun_sprite: Sprite2D = $player_gun_sprite
#@onready var gun_cursor_sprite: Sprite2D = $"../../gun_cursor_sprite"
@onready var gun_cursor_sprite: Sprite2D = $"../gun_cursor_sprite"
#@onready var cursor_anims: AnimationPlayer = $"../../cursor_anims"
@onready var cursor_anims: AnimationPlayer = $"../cursor_anims"
#@onready var player: CharacterBody2D = $"../.."
@onready var player: CharacterBody2D = $".."

# fields
var paused: bool = false
var sprite_facing_right: bool = true:
	set(new_val):
		if sprite_facing_right != new_val:
				player_sprite.scale.x *= -1
				player_gun_anchor.scale.y *= -1
		sprite_facing_right = new_val

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	cursor_anims.play("cursor")

func _process(_delta: float) -> void:
	player_gun_anchor.look_at(get_global_mouse_position())
	gun_cursor_sprite.global_position = get_global_mouse_position()
	if get_global_mouse_position().x < player.global_position.x:
		sprite_facing_right = false
		#player_sprite.scale *= -1
		#player_sprite.scale.y *= -1
		#player_sprite.flip_h = true
		#player_gun_sprite.flip_v = true
	else:
		sprite_facing_right = true
		#player_sprite.scale.x *
		#player_sprite.flip_h = false
		#player_gun_sprite.flip_v = false

	if Input.is_action_just_pressed("pause"):
		paused = !paused
	match paused:
		true:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		false:
			Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
