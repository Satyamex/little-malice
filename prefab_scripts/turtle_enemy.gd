extends CharacterBody2D

@onready var sprite: Sprite2D = $sprite
@onready var collider: CollisionShape2D = $collider
@onready var water_particles: GPUParticles2D = $Particles/Water
@onready var death_sfx: AudioStreamPlayer = $sfx/death_sfx
@onready var turtle_anims: AnimationPlayer = $turtle_anims

@export var speed: int = 120
@export var health: int = 2
@export var blood_particles: PackedScene
@export var attack_power: int = 1

var player: CharacterBody2D
var direction: Vector2
var died: bool = false

var sprite_facing_right: bool = true:
	set(new_val):
		if sprite_facing_right != new_val:
				sprite.scale.x *= -1
		sprite_facing_right = new_val

func _ready() -> void:
	sprite.set_material(sprite.get_material().duplicate(true))
	player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta: float) -> void:
	if not player or died:
		return
	direction = player.position - self.position
	if direction.length() > 40:
		if !turtle_anims.is_playing():
			turtle_anims.play("walk")
		velocity = direction.normalized() * speed
		move_and_slide()

func _process(_delta: float) -> void:
	if not player or died:
		return
	if player.global_position.x < self.global_position.x:
		sprite_facing_right = false
	else:
		sprite_facing_right = true
	if health <= 0:
		die()

func attack():
	turtle_anims.play("attack")
	var attack_direction = (player.global_position.x - self.global_position.x)
	water_particles.restart()
	water_particles.process_material.set("direction", Vector3(attack_direction, 0, 0))
	player.take_damage(attack_power)

func take_damage(damage: int):
	health -= damage
	sprite.material.set("shader_parameter/active", true)
	await get_tree().create_timer(.1).timeout
	sprite.material.set("shader_parameter/active", false)

func die():
	var rand: float = randf_range(-.25,.25)
	death_sfx.pitch_scale += rand
	death_sfx.play()
	player.cur_health += 1
	player.killcount += 1
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
