extends Node2D

@onready var ambient_audio: AudioStreamPlayer = $ambient_audio
const AMBIENT_TRACK = preload("uid://d2wxvgk3jtpka")

func _ready() -> void:
	ambient_audio.stream = AMBIENT_TRACK
	ambient_audio.play()
