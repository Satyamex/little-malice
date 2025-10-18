extends CharacterBody2D

const bomb_sprite = preload("uid://bp1gvjk5pe5ay")
const projectile_tscn = preload("uid://ctl8tli74apuc")
const projectile_sprite = preload("uid://bp1gvjk5pe5ay")

@onready var collider: CollisionShape2D = $collider
@onready var body_sprite: Sprite2D = $Sprites/body_sprite
@onready var hand_sprite: Sprite2D = $Sprites/hand_anchor/hand_sprite
@onready var bomb_spawnpos: Marker2D = $Sprites/hand_anchor/hand_sprite/bomb_spawnpos
@onready var bombs_container: Node2D = $bombs_container
@onready var sprites: Node2D = $Sprites
@onready var just_bomb_sprite: Sprite2D = $Sprites/hand_anchor/BombSprite

@export var speed: int = 60
@export var projectile_speed: int = 100
## damage dealt by this enemy in 1 attack
@export var attack_power: int = 1
@export var health: int = 30
@export var blood_particles: PackedScene

var player: CharacterBody2D
var direction: Vector2
var died: bool = false

var sprite_facing_right: bool = true:
	set(new_val):
		if sprite_facing_right != new_val:
				sprites.scale.x *= -1
		sprite_facing_right = new_val

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
	if player.global_position.x < self.global_position.x:
		sprite_facing_right = false
	else:
		sprite_facing_right = true
	
	if health <= 0:
		die()

func attack():
	just_bomb_sprite.visible = false
	var attack_direction = (player.global_position - bomb_spawnpos.global_position)
	var bomb = projectile_tscn.instantiate()
	bombs_container.add_child(bomb)
	#attack power of THIS enemy will be applied to the bullet
	bomb.damage = attack_power
	bomb.speed = projectile_speed
	bomb.sprite.texture = bomb_sprite
	bomb.scale = Vector2(4,4) # just size of this is larger than other projectiles
	bomb.rotate_after_thrown = true
	
	bomb.global_position = bomb_spawnpos.global_position
	#muzzle_flash_particles.global_position = bullet_spawnpos.global_position
	#muzzle_flash_particles.restart()
	#muzzle_flash_particles.process_material.set("direction", Vector3(direction.x, direction.y, 0))
	bomb.rotation = attack_direction.angle() + PI/2
	if bomb.has_method("shoot"):
		bomb.shoot(attack_direction, self)
		await get_tree().create_timer(.5).timeout
		just_bomb_sprite.visible = true


func take_damage(damage: int):
	health -= damage
	body_sprite.material.set("shader_parameter/active", true)
	hand_sprite.material.set("shader_parameter/active", true)
	await get_tree().create_timer(.1).timeout
	body_sprite.material.set("shader_parameter/active", false)
	hand_sprite.material.set("shader_parameter/active", false)

func die():
	player.cur_health += 1
	player.killcount += 1
	sprites.visible = false
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
