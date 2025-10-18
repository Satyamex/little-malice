extends CharacterBody2D

@onready var sprite: Sprite2D = $sprite
@onready var collider: CollisionShape2D = $collider
@onready var gun_sprite: Sprite2D = $gun_anchor/gun_sprite
@onready var gun_anchor: Node2D = $gun_anchor

@export var speed: int = 30
@export var health: int = 15
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
	if direction.length() > 100:
		velocity = direction.normalized() * speed
		move_and_slide()

func _process(_delta: float) -> void:
	if not player or died:
		return
	if player.position.x < position.x:
		sprite.flip_h = true
		gun_sprite.flip_v = true
	else:
		sprite.flip_h = false
		gun_sprite.flip_v = false
	if health <= 0:
		die()
	gun_anchor.look_at(player.position)

func take_damage(damage: int):
	health -= damage

func die():
	sprite.visible = false
	collider.disabled = true
	gun_sprite.visible = false
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
