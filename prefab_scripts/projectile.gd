extends Area2D


@onready var sprite: Sprite2D = $sprite
@export var speed: float = 500.0
@export var damage: int = 1

var rotation_tween: Tween

var rotate_after_thrown: bool = false:
	set(new_val):
		rotate_after_thrown = new_val
		if rotate_after_thrown:
			rotate_sprite()

var global_shooter: CharacterBody2D
var direction: Vector2 = Vector2.ZERO

func rotate_sprite():
	sprite.rotation_degrees = 0
	if rotation_tween and rotation_tween.is_running():
		rotation_tween.stop()
	rotation_tween = create_tween()
	rotation_tween.tween_property(sprite,"rotation_degrees",360,1)
	rotation_tween.connect("finished", rotate_sprite)

func shoot(dir: Vector2, Shooter:CharacterBody2D) -> void:
	global_shooter = Shooter 
	'if Shooter.is_in_group("player"):
		player_bullet.visible = true
	elif Shooter.is_in_group("enemy"):
		slime_bullet.visible = true'
	
	direction = dir.normalized()
	visible = true
	set_physics_process(true)
	await get_tree().create_timer(10).timeout
	reset_bullet()

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_Bullet_body_entered(body) -> void:
	if global_shooter.is_in_group("player"):
		if body.is_in_group("enemy"):
			reset_bullet()
			body.take_damage(damage)
	elif global_shooter.is_in_group("enemy"):
		if body.is_in_group("player"):
			reset_bullet()
			body.take_damage(damage)

func reset_bullet() -> void:
	self.queue_free()
