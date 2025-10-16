extends CharacterBody2D

@onready var player: CharacterBody2D = $"."
@onready var player_anims: AnimationPlayer = $player_anims

@export var speed: int = 80

func _physics_process(_delta: float) -> void:
	var direction: Vector2 = Vector2(Input.get_axis("ui_left","ui_right"), Input.get_axis("ui_up","ui_down"))
	if direction.length() > 0:
		direction = direction.normalized()
		player.velocity = player.velocity.lerp(direction * speed, _delta * 10)
		player_anims.play("walk")
	else:
		player.velocity = player.velocity.lerp(Vector2.ZERO, _delta * 10)
	player.move_and_slide()
