extends Node2D


@onready var click_sfx: AudioStreamPlayer = $click_sfx

func _on_pick_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.power_mode = true
		click_sfx.play()
		await get_tree().create_timer(.2).timeout
		queue_free() 
