extends StaticBody2D

@onready var _level := get_parent()

const LEFT: String = 'left'
const RIGHT: String = 'right'
const TOP: String = 'top'
const BOTTOM: String = 'bottom'

enum DIRECTION {TOP, BOTTOM, LEFT, RIGHT}
const PUSH_SPEED: float = 0.5

var tile_size_x = 0
var tile_size_y = 0

var pushing: bool = false
var target_x: float = 0
var target_y: float = 0

func _ready() -> void:
	tile_size_x = _level._tileMap.tile_set.tile_size.x
	tile_size_y = _level._tileMap.tile_set.tile_size.y
	position.x = snapped(position.x, tile_size_x)
	position.y = snapped(position.y, tile_size_y)
	target_x = position.x
	target_y = position.y

func can_push(direction: DIRECTION) -> bool:
	var new_x: float = position.x
	var new_y: float = position.y
	
	#if pushing:
	#	return false
		
	match direction:
		DIRECTION.TOP:
			new_y -= tile_size_y
		DIRECTION.BOTTOM:
			new_y += tile_size_y
		DIRECTION.LEFT:
			new_x -= tile_size_x
		DIRECTION.RIGHT:
			new_x += tile_size_x
			
	if _level.is_obstacle(new_x, new_y):
		return false
		
	if _level.get_box(new_x, new_y) != null:
		return false
		
	return true

func push(direction: DIRECTION) -> void:
	pushing = true
	match direction:
		DIRECTION.TOP:
			target_y -= tile_size_y
		DIRECTION.BOTTOM:
			target_y += tile_size_y
		DIRECTION.LEFT:
			target_x -= tile_size_x
		DIRECTION.RIGHT:
			target_x += tile_size_x
			
func _process(delta: float) -> void:
	position.x = lerp(position.x, target_x, PUSH_SPEED)
	position.y = lerp(position.y, target_y, PUSH_SPEED)
	
	if (round(position.x) == target_x && round(position.y) == target_y):
		position.x = snapped(position.x, tile_size_x)
		position.y = snapped(position.y, tile_size_y)
		pushing = false
		
