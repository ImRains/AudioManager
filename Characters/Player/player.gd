extends CharacterBody2D

# 移动参数
@export var speed : float = 140.0
@export var jump_velocity : float = -400.0
@export var gravity : float = 980.0

@onready var graphic: Node2D = $Graphic
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var run_sfx:AudioStream
@export var jump_sfx:AudioStream

func _physics_process(delta):
	# 应用重力（无论是否在地面）
	velocity.y += gravity * delta
	
	# 获取水平移动输入（自动处理相反方向同时按下）
	var horizontal_direction = Input.get_axis("move_left", "move_right")
	velocity.x = horizontal_direction * speed
	
	if horizontal_direction != 0:
		graphic.scale.x = horizontal_direction
	
	# 跳跃处理（需要在地面时才能跳）
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		AudioManager.play_sfx(jump_sfx)
	
	if not is_on_floor():
		animation_player.play("jump")
	elif velocity.x != 0:
		animation_player.play("run")
	else:
		animation_player.play("idle")
	
	# 应用最终速度并处理碰撞
	move_and_slide()

func play_run_sfx() -> void:
	AudioManager.play_sfx(run_sfx)
