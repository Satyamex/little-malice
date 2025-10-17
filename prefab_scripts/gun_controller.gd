extends Node2D
@onready var gun_cursor_sprite: Sprite2D = $"../gun_cursor_sprite"
@onready var bullet_spawnpos: Node2D = $"../player_gun_anchor/player_gun_sprite/bullet_spawnpos"
@onready var dash_particles: GPUParticles2D = $"../Particles/dash_particles"
@onready var muzzle_flash_particles: GPUParticles2D = $"../Particles/muzzle_flash_particles"

var shoot_cooldown: float
var can_shoot: bool = true

@export var player_bullet: PackedScene

func _ready() -> void:
	shoot_cooldown = muzzle_flash_particles.lifetime + muzzle_flash_particles.lifetime / 2
	await get_tree().create_timer(muzzle_flash_particles.lifetime + 0.5).timeout
	muzzle_flash_particles.emitting = false

func _process(_delta: float) -> void:
	if Input.is_action_pressed("shoot") and can_shoot:
		can_shoot = false
		shoot_bullet()
	

func shoot_bullet() -> void:
	var bullet = player_bullet.instantiate()
	add_child(bullet)
	bullet.global_position = bullet_spawnpos.global_position
	var direction = (gun_cursor_sprite.global_position - bullet_spawnpos.global_position).normalized()
	muzzle_flash_particles.global_position = bullet_spawnpos.global_position
	muzzle_flash_particles.restart()
	muzzle_flash_particles.process_material.set("direction", Vector3(direction.x, direction.y, 0))
	bullet.rotation = direction.angle() + PI/2
	if bullet.has_method("shoot"):
		bullet.shoot(direction)
		await get_tree().create_timer(shoot_cooldown).timeout
		can_shoot = true
