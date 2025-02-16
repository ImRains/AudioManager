extends Node2D

@export var bg_music1:AudioStream
@export var bg_music2:AudioStream
@export var bg_music3:AudioStream

func _ready() -> void:
	AudioManager.play_music(bg_music1)


func _on_global_volume_slider_value_changed(value: float) -> void:
	print("[全局音量]:", value)
	AudioManager.set_volume(AudioManager.Bus.MASTER, value)


func _on_bg_volume_slider_value_changed(value: float) -> void:
	print("[音乐音量]:", value)
	AudioManager.set_volume(AudioManager.Bus.MUSIC, value)


func _on_sfx_volume_slider_value_changed(value: float) -> void:
	print("[音效音量]:", value)
	AudioManager.set_volume(AudioManager.Bus.SFX, value)


func _on_bgm_1_pressed() -> void:
	print("[播放音乐1]")
	AudioManager.play_music(bg_music1)


func _on_bgm_2_pressed() -> void:
	print("[播放音乐2]")
	AudioManager.play_music(bg_music2)


func _on_bgm_3_pressed() -> void:
	print("[播放音乐3]")
	AudioManager.play_music(bg_music3)
