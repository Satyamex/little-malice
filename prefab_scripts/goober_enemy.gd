extends CharacterBody2D

const projectile_tscn = preload("uid://ctl8tli74apuc") #plyaer bullet scene
const slime_bullet_sprite = preload("uid://hmxj5jbepehq")

@onready var sprite: Sprite2D = $sprite
@onready var collider: CollisionShape2D = $collider
@onready var gun_sprite: Sprite2D = $gun_anchor/gun_sprite
@onready var gun_anchor: Node2D = $gun_anchor
@onready var bullet_spawnpos: Marker2D = $gun_anchor/gun_sprite/bullet_spawnpos
@onready var muzzle_flash_particles: GPUParticles2D = $Particles/muzzle_flash_particles
@onready var bullet_container: Node2D = $bullet_container
@onready var death_sfx: AudioStreamPlayer = $sfx/death_sfx
@onready var goober_anims: AnimationPlayer = $goober_anims

@export var speed: int = 30
@export var projectile_speed: int = 450
@export var health: int = 15
## damage dealt by this enemy in 1 attack
@export var attack_power: int = 1
@export var blood_particles: PackedScene

var player: CharacterBody2D
var direction: Vector2
var died: bool = false

func _ready() -> void:
	sprite.set_material(sprite.get_material().duplicate(true))
	#shoot_cooldown = muzzle_flash_particles.lifetime + muzzle_flash_particles.lifetime / 2
	await get_tree().create_timer(muzzle_flash_particles.lifetime + 0.5).timeout
	muzzle_flash_particles.emitting = false
	player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta: float) -> void:
	if not player or died:
		return
	direction = player.position - self.position
	if direction.length() > 100:
		if !goober_anims.is_playing():
			goober_anims.play("walk")
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

func attack() -> void:
	goober_anims.play("attack")
	var attack_direction = (player.global_position - bullet_spawnpos.global_position)
	var bullet = projectile_tscn.instantiate()
	bullet_container.add_child(bullet)
	
	#attack power of THIS enemy will be applied to the bullet
	bullet.damage = attack_power
	bullet.speed = projectile_speed
	bullet.sprite.texture = slime_bullet_sprite
	
	bullet.global_position = bullet_spawnpos.global_position
	muzzle_flash_particles.global_position = bullet_spawnpos.global_position
	muzzle_flash_particles.restart()
	muzzle_flash_particles.process_material.set("direction", Vector3(direction.x, direction.y, 0))
	bullet.rotation = attack_direction.angle() + PI/2
	if bullet.has_method("shoot"):
		bullet.shoot(attack_direction, self)

func take_damage(damage: int):
	health -= damage
	sprite.material.set("shader_parameter/active", true)
	await get_tree().create_timer(.1).timeout
	sprite.material.set("shader_parameter/active", false)

func die():
	var rand: float = randf_range(-.25,.25)
	death_sfx.pitch_scale += rand
	death_sfx.play()
	player.cur_health += 2
	player.killcount += 1
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
