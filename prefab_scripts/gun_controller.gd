extends Node

@onready var gun_cursor_sprite: Sprite2D = $"../gun_cursor_sprite"
@onready var bullet_spawnpos: Marker2D = $"../player_gun_anchor/player_gun_sprite/bullet_spawnpos"
@onready var dash_particles: GPUParticles2D = $"../Particles/dash_particles"
@onready var muzzle_flash_particles: GPUParticles2D = $"../Particles/muzzle_flash_particles"
@onready var gun_anims: AnimationPlayer = $"../gun_anims"
@onready var bullets_container: Node2D = $"../Bullets_container"
@onready var player: CharacterBody2D = $".."
@onready var gun_sfx: AudioStreamPlayer = $"../Sfx/gun_sfx"
@onready var flame_thrower_particles: GPUParticles2D = $"../Particles/flame_thrower_particles"
@onready var firestart_pos: Marker2D = $"../player_gun_anchor/flamethrower_sprite/firestart_pos"
@onready var flame_area: Area2D = $"../FlameArea"
@onready var flame_dps_timer: Timer = $"../FlameArea/flame_dps_timer"
@onready var flamethrower_sfx: AudioStreamPlayer = $"../Sfx/flamethrower_sfx"

@export var player_bullet: PackedScene
@export var fire_dmg: int = 2

var shoot_cooldown: float
var can_shoot: bool = true
var og_pitch_scale: float 

var bodies_in_flame_area: Array = []


func _ready() -> void:
	og_pitch_scale = gun_sfx.pitch_scale
	shoot_cooldown = muzzle_flash_particles.lifetime + muzzle_flash_particles.lifetime / 2
	await get_tree().create_timer(muzzle_flash_particles.lifetime + 0.5).timeout
	muzzle_flash_particles.emitting = false

func _process(_delta: float) -> void:
	if !player.power_mode:
		if Input.is_action_pressed("shoot") and can_shoot:
			shoot_bullet()
	else:
		if Input.is_action_pressed("shoot"):
			flame_on()
		else:
			flame_thrower_particles.emitting = false
			flamethrower_sfx.stop()
			flame_dps_timer.stop()

func flame_on():
	if flame_dps_timer.is_stopped():
		flame_dps_timer.start()
	
	if !flamethrower_sfx.playing:
		flamethrower_sfx.play()
	
	var direction:Vector2 = (gun_cursor_sprite.global_position - firestart_pos.global_position)
	flame_thrower_particles.emitting = true
	flame_thrower_particles.global_position = firestart_pos.global_position
	flame_thrower_particles.process_material.set("direction", Vector3(direction.x, direction.y, 0))
	flame_area.look_at(gun_cursor_sprite.global_position)

func shoot_bullet() -> void:
	var direction = (gun_cursor_sprite.global_position - bullet_spawnpos.global_position)
	if direction.length() < 20:
		return
	can_shoot = false
	var rand: float = randf_range(-.25,.25)
	gun_sfx.pitch_scale += rand
	gun_sfx.play()
	gun_anims.play("GunFire")
	var bullet = player_bullet.instantiate()
	bullets_container.add_child(bullet)
	bullet.global_position = bullet_spawnpos.global_position
	muzzle_flash_particles.global_position = bullet_spawnpos.global_position
	muzzle_flash_particles.restart()
	muzzle_flash_particles.process_material.set("direction", Vector3(direction.x, direction.y, 0))
	bullet.rotation = direction.angle() + PI/2
	if bullet.has_method("shoot"):
		bullet.shoot(direction, player)
		await get_tree().create_timer(shoot_cooldown).timeout
		can_shoot = true


func _on_gun_sfx_finished() -> void:
	gun_sfx.pitch_scale = og_pitch_scale


func _on_flame_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") and body not in bodies_in_flame_area:
		bodies_in_flame_area.append(body)


func _on_flame_area_body_exited(body: Node2D) -> void:
	if body in bodies_in_flame_area:
		bodies_in_flame_area.erase(body)


func _on_flame_dps_timer_timeout() -> void:
	for body in bodies_in_flame_area:
		body.take_damage(fire_dmg)
