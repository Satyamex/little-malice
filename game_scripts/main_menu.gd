extends Control

const STAGE = preload("uid://d7w8dcndov3c")
const LITTLE_MALICE_MAIN = preload("uid://dymwewwcmn5vp")

@onready var bg_music: AudioStreamPlayer = $bg_music

func _ready() -> void:
	bg_music.stream = LITTLE_MALICE_MAIN
	bg_music.play()

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_packed(STAGE)

func _on_about_button_pressed() -> void:
	OS.shell_open("https://radint.itch.io/little-malice")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
