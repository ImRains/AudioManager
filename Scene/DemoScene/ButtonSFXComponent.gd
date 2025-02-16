class_name ButtonSFXComponent extends Node

@export var click_sfx: AudioStream
@export var hover_sfx: AudioStream

var target: BaseButton


func _ready() -> void:
	target = get_parent()
	make_connection()


func make_connection() -> void:
	target.mouse_entered.connect(on_hover)
	target.pressed.connect(pressed_handler)


func on_hover() -> void:
	AudioManager.play_sfx(hover_sfx, true)

func pressed_handler() -> void:
	AudioManager.play_sfx(click_sfx)
