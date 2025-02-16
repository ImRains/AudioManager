extends Node

enum Bus {
	MASTER,
	MUSIC,
	SFX,
}

const MUSIC_BUS = "Music"
const SFX_BUS = "SFX"

## 音乐播放器个数
var music_audio_player_count: int = 2
var current_music_player_index: int = 0
var music_players: Array[AudioStreamPlayer]

## 音效播放器(游戏)
var game_sfx_audio_player_count: int = 6
var game_sfx_players: Array[AudioStreamPlayer]


func _ready() -> void:
	print("[全局音乐器]: 加载完成")
	init_music_audio_player()
	init_game_sfx_audio_player()


## 初始化音乐播放器
func init_music_audio_player() -> void:
	for i in music_audio_player_count:
		var audio_player := AudioStreamPlayer.new()
		audio_player.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(audio_player)
		audio_player.bus = MUSIC_BUS
		music_players.append(audio_player)


## 初始化音效播放器
func init_game_sfx_audio_player() -> void:
	for i in game_sfx_audio_player_count:
		var audio_player := AudioStreamPlayer.new()
		add_child(audio_player)
		audio_player.bus = SFX_BUS
		game_sfx_players.append(audio_player)


## 播放音乐
func play_music(_audio: AudioStream) -> void:
	if _audio == music_players[current_music_player_index].stream:
		return
	var current_audio_player := music_players[current_music_player_index]
	current_audio_player.stream = _audio
	current_audio_player.play(0)
	var old_audio_player_index = 0 if current_music_player_index == 1 else 1
	var old_audio_player := music_players[old_audio_player_index]
	old_audio_player.stop()
	old_audio_player.stream = null
	current_music_player_index = 1 if current_music_player_index == 0 else 0


## 播放音效
func play_sfx(_audio: AudioStream, _is_random_pitch: bool = false) -> void:
	var pitch := 1.0
	if _is_random_pitch:
		pitch = randf_range(0.95, 1.05)
	var idx: int = -1
	var players := game_sfx_players
	for i in players.size():
		var sfx_audio_player := players[i]
		if sfx_audio_player.playing:
			continue
		sfx_audio_player.stream = _audio
		sfx_audio_player.pitch_scale = pitch
		sfx_audio_player.play()
		idx = i
		break


## 设置指定声音管线的音量
func set_volume(bus_index: Bus, v: float) -> void:
	var db := linear_to_db(v)
	AudioServer.set_bus_volume_db(bus_index, db)
