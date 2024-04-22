extends CharacterBody2D

# How many pixels player move
const MOVE_STEP = 64
# Movement speed
const SPEED = 0.3

enum DIRECTION {TOP, BOTTOM, LEFT, RIGHT, STATIC}
var direction:DIRECTION = DIRECTION.STATIC
var animation_direction:DIRECTION = DIRECTION.STATIC
var target_x:int = 0
var target_y:int = 0

var is_win: bool = false

@onready var _animatedSprite := $AnimatedSprite2D
@onready var _level := get_parent()
@onready var _animationPlayer := $AnimationPlayer

func _ready() -> void:
	position.x = snapped(position.x, MOVE_STEP)
	position.y = snapped(position.y, MOVE_STEP)
	target_x = floor(position.x)
	target_y = floor(position.y)

func _process(delta: float) -> void:
	if is_win:
		return
		
	if direction == DIRECTION.STATIC:
		if Input.is_action_just_pressed("move_left"):
			direction = DIRECTION.LEFT
			target_x -= MOVE_STEP
		elif Input.is_action_just_pressed("move_right"):
			direction = DIRECTION.RIGHT
			target_x += MOVE_STEP
		elif Input.is_action_just_pressed("move_top"):
			direction = DIRECTION.TOP
			target_y -= MOVE_STEP
		elif Input.is_action_just_pressed("move_bottom"):
			direction = DIRECTION.BOTTOM
			target_y += MOVE_STEP
		
func _physics_process(delta: float) -> void:
	if is_win:
		return
		
	if (direction != DIRECTION.STATIC && not can_move()):
		direction = DIRECTION.STATIC
		target_x = snapped(position.x, MOVE_STEP)
		target_y = snapped(position.y, MOVE_STEP)
		
		return
	
	position.y = lerp(position.y, target_y * 1.0, SPEED)
	position.x = lerp(position.x, target_x * 1.0, SPEED)
	
	set_animation()
	
	var box = _level.get_box(target_x, target_y)
	if (box != null && box.can_push(direction) && not box.pushing):
		box.push(direction)
	
	if (round(position.x) == target_x && round(position.y) == target_y):
		position.x = snapped(position.x, MOVE_STEP)
		position.y = snapped(position.y, MOVE_STEP)
		direction = DIRECTION.STATIC

# Test if player can move to direction	
func can_move() -> bool:
	if _level.is_obstacle(target_x, target_y):
		return false
		
	var box = _level.get_box(target_x, target_y)
	if (box != null):
		return box.can_push(direction)
		
	return true
	
func set_animation() -> void:
	# Not moving
	if (direction == DIRECTION.STATIC):
		match animation_direction:
			DIRECTION.LEFT:
				_animatedSprite.play("idle_left")
			DIRECTION.RIGHT:
				_animatedSprite.play("idle_right")
			DIRECTION.TOP:
				_animatedSprite.play("idle_top")
			DIRECTION.BOTTOM:
				_animatedSprite.play("idle_bottom")
		return
	# In move
	animation_direction = direction
	
	match direction:
		DIRECTION.LEFT:
			_animatedSprite.play("move_left")
		DIRECTION.RIGHT:
			_animatedSprite.play("move_right")
		DIRECTION.TOP:
			_animatedSprite.play("move_top")
		DIRECTION.BOTTOM:
			_animatedSprite.play("move_bottom")

func win() -> void:
	is_win = true
	_animatedSprite.play('idle_bottom')
	_animationPlayer.play('win', -1, 3.0)
