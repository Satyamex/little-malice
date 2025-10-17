extends Area2D

@export var speed: float = 500.0
var direction: Vector2 = Vector2.ZERO

func shoot(dir: Vector2) -> void:
	direction = dir.normalized()
	visible = true
	set_physics_process(true)
	await get_tree().create_timer(10).timeout
	reset_bullet()

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_Bullet_body_entered(body) -> void:
	if body.is_in_group("player"):
		return
	reset_bullet()

func reset_bullet() -> void:
	self.queue_free()
