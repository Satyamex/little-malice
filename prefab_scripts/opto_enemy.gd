extends CharacterBody2D

@onready var sprite: Sprite2D = $sprite
@onready var collider: CollisionShape2D = $collider
@onready var left_slash: AnimatedSprite2D = $LeftSlash
@onready var right_slash: AnimatedSprite2D = $RightSlash

@export var speed: int = 40
## damage dealt by this enemy in 1 attack
@export var attack_power: int = 1
@export var health: int = 115
@export var blood_particles: PackedScene

var player: CharacterBody2D
var direction: Vector2
var died: bool = false

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta: float) -> void:
	if not player or died:
		return
	direction = player.position - self.position
	if direction.length() > 160:
		velocity = direction.normalized() * speed
		move_and_slide()

func _process(_delta: float) -> void:
	if not player or died:
		return
	if player.position.x < position.x:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	if health <= 0:
		die()

func attack():
	left_slash.flip_h = false
	right_slash.flip_h = true
	if player.global_position.x < self.global_position.x:
		if player.global_position.y < self.global_position.y:
			left_slash.flip_h = true
		left_slash.play("Slash")
	else:
		if player.global_position.y < self.global_position.y:
			right_slash.flip_h = false
		right_slash.play("Slash")
	player.take_damage(attack_power)

func take_damage(damage: int):
	health -= damage
	sprite.material.set("shader_parameter/active", true)
	await get_tree().create_timer(.1).timeout
	sprite.material.set("shader_parameter/active", false)

func die():
	sprite.visible = false
	collider.disabled = true
	var blood = blood_particles.instantiate()
	add_child(blood)
	blood.global_position = global_position
	var emitter = blood.get_child(0)
	emitter.emitting = true
	died = true
	await get_tree().create_timer(0.35).timeout
	emitter.emitting = false
	emitter.process_mode = Node.PROCESS_MODE_DISABLED
	await get_tree().create_timer(9).timeout
	emitter.process_mode = Node.PROCESS_MODE_INHERIT
	emitter.emitting = true
	await get_tree().create_timer(1).timeout
	queue_free()
