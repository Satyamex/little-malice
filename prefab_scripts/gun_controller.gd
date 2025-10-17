extends Node2D

@onready var muzzle_flash_particles: GPUParticles2D = $"../player_sprite/player_gun_anchor/player_gun_sprite/muzzle_flash_particles"
@onready var gun_cursor_sprite: Sprite2D = $"../gun_cursor_sprite"
@onready var bullet_spawnpos: Node2D = $"../player_sprite/player_gun_anchor/player_gun_sprite/muzzle_flash_particles/bullet_spawnpos"

var shoot_cooldown: float
var can_shoot: bool = true

@export var player_bullet: PackedScene

func _ready() -> void:
	shoot_cooldown = muzzle_flash_particles.lifetime + muzzle_flash_particles.lifetime / 2
	await get_tree().create_timer(muzzle_flash_particles.lifetime + 0.5).timeout
	muzzle_flash_particles.emitting = false

func _process(delta: float) -> void:
	if Input.is_action_pressed("shoot") and can_shoot:
		muzzle_flash_particles.emitting = true
		can_shoot = false
		shoot_bullet()
	else:
		muzzle_flash_particles.emitting = false

func shoot_bullet() -> void:
	var bullet = player_bullet.instantiate()
	add_child(bullet)
	bullet.global_position = bullet_spawnpos.global_position
	var direction = (gun_cursor_sprite.global_position - bullet.global_position).normalized()
	#bullet.look_at(direction)
	bullet.rotation = direction.angle() + PI/2
	if bullet.has_method("shoot"):
		bullet.shoot(direction)
		await get_tree().create_timer(shoot_cooldown).timeout
		can_shoot = true
