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
## 音乐渐入渐出
var music_fade_duration: float = 1.0

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
	var old_audio_player_index = 0 if current_music_player_index == 1 else 1
	var old_audio_player := music_players[old_audio_player_index]
	if old_audio_player.stream == _audio:
		return
	current_audio_player.stream = _audio
	play_and_fade_in(current_audio_player)
	
	# 关闭之前的播放器
	fade_out_and_sotp(old_audio_player)
	# 修改current_music_player_index
	current_music_player_index = 1 if current_music_player_index == 0 else 0

## 播放音乐并渐入
func play_and_fade_in(_audio_player: AudioStreamPlayer) -> void:
	_audio_player.play(0)
	var tween: Tween = create_tween()
	tween.tween_property(_audio_player, "volume_db", 0, music_fade_duration)

## 停止播放并渐出
func fade_out_and_sotp(_audio_player: AudioStreamPlayer) -> void:
	var tween: Tween = create_tween()
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

## 播放音效
func play_sfx(_audio:AudioStream, _is_random_pitch:bool = false) -> void:
	var pitch := 1.0
	if _is_random_pitch:
		pitch = randf_range(0.9, 1.1)
	for i in sfx_players.size():
		var sfx_audio_player := sfx_players[i]
		if not sfx_audio_player.playing:
			sfx_audio_player.stream = _audio
			sfx_audio_player.pitch_scale = pitch
			sfx_audio_player.play(0)
			break

## 设置制定声音管线的音量 v 是音量 取值 0-1
func set_volume(bus_index: Bus, v: float) -> void:
	var db := linear_to_db(v)
	AudioServer.set_bus_volume_db(bus_index, db)
