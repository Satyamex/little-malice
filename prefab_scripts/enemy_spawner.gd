extends Node2D

@export var spawn_points: Array[Marker2D] = []
@export var enemies: Array[PackedScene] = []

var spawn_timer: float = 2
var player: Node

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	await get_tree().create_timer(2).timeout
	spawn()

func _process(_delta: float) -> void:
	spawn_timer = get_spawn_time(player.killcount)

func spawn() -> void:
	var enemy: int = randi_range(0, 24)
	var spawner_id: int = randi_range(0, spawn_points.size() - 1)
	var enemy_to_spawn: PackedScene
	var selected_spawner: Marker2D
	if enemy < 9: enemy_to_spawn = enemies[0]
	elif enemy < 18: enemy_to_spawn = enemies[1]
	elif enemy < 22: enemy_to_spawn = enemies[2]
	elif enemy <= 24: enemy_to_spawn = enemies[3]
	print(enemy)
		#0: enemy_to_spawn = enemies[0]
		#1: enemy_to_spawn = enemies[1]
		#2: enemy_to_spawn = enemies[2]
		#3: enemy_to_spawn = enemies[3]
	match spawner_id:
		0: selected_spawner = spawn_points[0]
		1: selected_spawner = spawn_points[1]
		2: selected_spawner = spawn_points[2]
		3: selected_spawner = spawn_points[3]
		4: selected_spawner = spawn_points[4]
		5: selected_spawner = spawn_points[5]
		6: selected_spawner = spawn_points[6]
		7: selected_spawner = spawn_points[7]
		8: selected_spawner = spawn_points[8]
		9: selected_spawner = spawn_points[9]
		10: selected_spawner = spawn_points[10]
		11: selected_spawner = spawn_points[11]
		12: selected_spawner = spawn_points[12]
		13: selected_spawner = spawn_points[13]
		14: selected_spawner = spawn_points[14]
		15: selected_spawner = spawn_points[15]
		16: selected_spawner = spawn_points[16]
		17: selected_spawner = spawn_points[17]
		18: selected_spawner = spawn_points[18]
		19: selected_spawner = spawn_points[19]
		20: selected_spawner = spawn_points[20]
	var spawned_enemy: = enemy_to_spawn.instantiate()
	add_sibling(spawned_enemy)
	spawned_enemy.position = selected_spawner.position
	await  get_tree().create_timer(spawn_timer).timeout
	spawn()

func get_spawn_time(kills: int) -> float:
	var base_time := 2.0
	var min_time := 0.5
	var spawn_time := base_time
	if kills < 5:
		spawn_time = base_time
	elif kills < 10:
		spawn_time -= 0.5 
	elif kills < 20:
		spawn_time -= 0.8
	else:
		var extra_stages := int((kills - 20) / 10)
		spawn_time -= 0.8 + extra_stages * 0.1
	return max(spawn_time, min_time)
