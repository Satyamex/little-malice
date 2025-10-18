extends CharacterBody2D

@onready var player_anims: AnimationPlayer = $player_anims
@onready var player_sprite: Sprite2D = $player_sprite
@onready var walk_particles: GPUParticles2D = $Particles/walk_particles
@onready var dash_particles: GPUParticles2D = $Particles/dash_particles
@onready var health_bar: TextureProgressBar = $CanvasLayer/Health/HealthBar

@onready var top_limit: Marker2D = $"../cam_limits/top_limit"
@onready var down_limit: Marker2D = $"../cam_limits/down_limit"
@onready var left_limit: Marker2D = $"../cam_limits/left_limit"
@onready var right_limit: Marker2D = $"../cam_limits/right_limit"


@onready var cam: Camera2D = $Cam

@export var max_health: int = 5
@export var speed: int = 80
@export var dash_speed: int = speed * 3
@export var dash_duration: float = 0.15
@export var dash_cooldown: float = 1.4

var health_tween: Tween

var cur_health: int:
	set(new_val):
		if cur_health != new_val:
			cur_health = new_val
			cur_health = clampi(cur_health, 0, max_health)
			if health_tween and health_tween.is_running():
				health_tween.stop()
			health_tween = create_tween()
			health_tween.tween_property(health_bar,"value",cur_health,.25).set_trans(Tween.TRANS_CUBIC)
			#health_bar.value = cur_health
			

var dashing: bool = false
var dash_timer: float = 0.0
var dashed: bool = false
var direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	cam.limit_top = int(top_limit.global_position.y)
	cam.limit_bottom = int(down_limit.global_position.y)
	cam.limit_left = int(left_limit.global_position.x)
	cam.limit_right = int(right_limit.global_position.x)
	
	cur_health = max_health
	health_bar.max_value = max_health
	dash_particles.visible = false
	walk_particles.visible = false
	dash_particles.one_shot = true
	dash_particles.emitting = true
	walk_particles.emitting = true
	await get_tree().create_timer(max(dash_particles.lifetime, walk_particles.lifetime)).timeout
	dash_particles.emitting = false
	walk_particles.emitting = false
	dash_particles.visible = true
	walk_particles.visible = true

func _process(_delta: float) -> void:
	direction = Vector2(Input.get_axis("move_left","move_right"), Input.get_axis("move_up","move_down"))
	if not dashing:
		if Input.is_action_just_pressed("dash") and direction != Vector2.ZERO and not dashed:
			dashing = true
			dashed = true
			
			dash_particles.process_material.set("direction", Vector3(-direction.x, -direction.y, 0))
			dash_timer = dash_duration
			replenish_dash()
			dash_particles.emitting = true
	elif dashing:
		dash_timer -= _delta
		if dash_timer <= 0:
			dashing = false

	if dashing:
		if direction.x > 0:
			player_anims.play("dash")
		elif direction.x < 0:
			player_anims.play("dash_2")
	elif direction.length() > 0:
		player_anims.play("walk")
		walk_particles.emitting = true
	else:
		walk_particles.emitting = false
		player_anims.pause()

func _physics_process(_delta: float) -> void:
	if dashing:
		self.velocity = direction.normalized() * dash_speed
	else:
		if direction.length() > 0:
			self.velocity = self.velocity.lerp(direction.normalized() * speed, _delta * 10)
		else:
			self.velocity = self.velocity.lerp(Vector2.ZERO, _delta * 100)
	move_and_slide()

func take_damage(damage):
	cur_health -= damage
	player_sprite.material.set("shader_parameter/active", true)
	await get_tree().create_timer(.1).timeout
	player_sprite.material.set("shader_parameter/active", false)


func replenish_dash() -> void:
	await get_tree().create_timer(dash_cooldown).timeout
	dashed = false


func _on_health_bar_value_changed(value: float) -> void:
	if value <= 0:
		print('you died')
