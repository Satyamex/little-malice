extends Node

@onready var enemy: CharacterBody2D = $".."
@onready var attack_cooldown_timer: Timer = $"../attack_cooldown"

@export var attack_cooldown_dur: float = 1.5

var player_in_range: bool = false:
	set(new_val):
		if player_in_range != new_val:
			player_in_range = new_val
			if attack_cooldown_timer and !enemy.died:
				attack_cooldown_timer.start()

func _on_attack_range_body_entered(body: Node2D) -> void:
	if enemy.player and body == enemy.player:
		player_in_range = true

func _on_attack_range_body_exited(_body: Node2D) -> void:
	if player_in_range:
		player_in_range = false

func _on_attack_cooldown_timeout() -> void:
	if player_in_range and !enemy.died:
		enemy.attack()
