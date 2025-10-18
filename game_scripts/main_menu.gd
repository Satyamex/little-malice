extends Control

const STAGE = preload("uid://d7w8dcndov3c")
const LITTLE_MALICE_MAIN = preload("uid://dymwewwcmn5vp")

@onready var bg_music: AudioStreamPlayer = $bg_music
@onready var hover_sfx: AudioStreamPlayer = $Hover_sfx
@onready var click_sfx: AudioStreamPlayer = $click_sfx
@onready var transition_anim: AnimationPlayer = $transition_anim
@onready var play_button: Button = $button_container/play_button
@onready var quit_button: Button = $button_container/quit_button
@onready var about_button: Button = $button_container/about_button

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	bg_music.stream = LITTLE_MALICE_MAIN
	bg_music.play()

func _on_play_button_pressed() -> void:
	play_button.disabled = true
	click_sfx.play()
	transition_anim.play_backwards("TransitionStart")
	await transition_anim.animation_finished
	get_tree().change_scene_to_packed(STAGE)
	

func _on_about_button_pressed() -> void:
	about_button.disabled = true
	click_sfx.play()
	await click_sfx.finished
	OS.shell_open("https://radint.itch.io/little-malice")
	

func _on_quit_button_pressed() -> void:
	quit_button.disabled = true
	click_sfx.play()
	await click_sfx.finished
	get_tree().quit()
	


func _on_quit_button_mouse_entered() -> void:
	hover_sfx.play()


func _on_about_button_mouse_entered() -> void:
	hover_sfx.play()


func _on_play_button_mouse_entered() -> void:
	hover_sfx.play()
