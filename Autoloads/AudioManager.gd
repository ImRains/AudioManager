extends Node

enum Bus {
	MASTER,
	MUSIC,
	SFX,
}

const MUSIC_BUS = "Music"
const SFX_BUS = "SFX"

## 音乐播放器配置
## 音乐播放器的个数
var music_audio_player_count: int = 2
## 当前播放音乐的播放器的序号，默认是0
var current_music_player_index: int = 0
## 音乐播放器存放的数组，方便调用
var music_players: Array[AudioStreamPlayer]
## 音乐渐变时长
var music_fade_duration:float = 1.0

## 音效播放器的个数
var sfx_audio_player_count: int = 6
## 音效播放器存放的数组，方便调用
var sfx_players: Array[AudioStreamPlayer]

func _ready() -> void:
	print("[声音管理器]: 加载完成")
	init_music_audio_manager()
	init_sfx_audio_manager()

## 初始化音乐播放器
func init_music_audio_manager() -> void:
	for i in music_audio_player_count:
		var audio_player := AudioStreamPlayer.new()
		audio_player.process_mode = Node.PROCESS_MODE_ALWAYS
		audio_player.bus = MUSIC_BUS
		add_child(audio_player)
		music_players.append(audio_player)

## 播放指定音乐
func play_music(_audio: AudioStream) -> void:
	var current_audio_player := music_players[current_music_player_index]
	if current_audio_player.stream == _audio:
		return
	var empty_audio_player_index = 0 if current_music_player_index == 1 else 1
	var empty_audio_player := music_players[empty_audio_player_index]
	# 渐入
	empty_audio_player.stream = _audio
	play_and_fade_in(empty_audio_player)
	# 渐出
	fade_out_and_stop(current_audio_player)
	current_music_player_index = empty_audio_player_index

## 渐入
func play_and_fade_in(_audio_player: AudioStreamPlayer) -> void:
	_audio_player.play()
	var tween:Tween = create_tween()
	tween.tween_property(_audio_player, "volume_db", 0, music_fade_duration)

## 渐出
func fade_out_and_stop(_audio_player: AudioStreamPlayer) -> void:
	var tween:Tween = create_tween()
	tween.tween_property(_audio_player, "volume_db", -40, music_fade_duration) 
	await tween.finished
	_audio_player.stop()
	_audio_player.stream = null

## 初始化音效播放器
func init_sfx_audio_manager() -> void:
	for i in sfx_audio_player_count:
		var audio_player := AudioStreamPlayer.new()
		audio_player.bus = SFX_BUS
		add_child(audio_player)
		sfx_players.append(audio_player)

## 播放指定音效
func play_sfx(_audio: AudioStream, _is_random_pitch:bool = false) -> void:
	var pitch := 1.0
	if _is_random_pitch:
		pitch = randf_range(0.9, 1.1)
	for i in sfx_audio_player_count:
		var sfx_audio_player := sfx_players[i]
		if not sfx_audio_player.playing:
			sfx_audio_player.stream = _audio
			sfx_audio_player.pitch_scale = pitch
			sfx_audio_player.play()
			break

## 设置总线的音量
func set_volume(bus_index:Bus, v:float) -> void:
	var db := linear_to_db(v)
	AudioServer.set_bus_volume_db(bus_index, db)
