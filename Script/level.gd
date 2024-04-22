extends Game

# Entities
@onready var _player: PackedScene = preload("res://Entity/player.tscn")
@onready var _box: PackedScene = preload("res://Entity/box.tscn")

var boxes: Array = []
var player: Node = null
var target_count: int = 0
var delta_time: float = 0.0
var time: int = 0

@onready var _timer := $WinTimer
@onready var _retryBtn := $Control/PanelContainer/MarginContainer/VBoxContainer/ButtonRetry
@onready var _editorBtn := $Control/PanelContainer/MarginContainer/VBoxContainer/ButtonEditor
@onready var _timeLabel := $Control/PanelContainer/MarginContainer/VBoxContainer/LabelTime
@onready var _levelLabel := $Control/PanelContainer/MarginContainer/VBoxContainer/LabelLevel

func _ready() -> void:
	_timer.timeout.connect(self.goto_next_level)
	_retryBtn.pressed.connect(self.retry)
	_editorBtn.pressed.connect(self.goto_editor)
	# Load level
	await load_level(level)
	generate_level()
	

func generate_level() -> void:
	target_count = 0
	# Explore map and create entities
	for cell in _tileMap.get_used_cells(1):
		var data: TileData = _tileMap.get_cell_tile_data(1, cell)
		if data == null:
			continue
		var position: Vector2 = _tileMap.map_to_local(cell)
		var name: String = data.get_custom_data("name")
		var entity: Node = null
		match name:
			"Box":
				entity = _box.instantiate()
				boxes.push_back(entity)
			"Player":
				if null == player:
					entity = _player.instantiate()
					player = entity
			"Target":
				target_count += 1
				
		if entity != null:
			_tileMap.erase_cell(1, cell)
			# Substract 1 px to get right snapped coords
			entity.position = position - Vector2(1, 1)
			add_child(entity)
			entity.set_z_index(1)
			
		_levelLabel.set_text(str(level))
		
# Delete all entities and set time to 0
func reset_level() -> void:
	if (player != null):
		player.is_win = false
		remove_child(player)
		player = null
		
	for boxe: Node in boxes:
		remove_child(boxe)
		
	boxes = []
	
	time = 0
	_timeLabel.set_text("0")

func _process(delta: float) -> void:
	if null != player && is_win() && not player.is_win:
		player.win()
		_timer.start()
		
	if not is_win():
		delta_time += delta
		if delta_time >= 1.0:
			delta_time -= 1.0
			time += 1
			_timeLabel.set_text(str(time))
		
func is_obstacle(x: int, y: int) -> bool:
	var tile_x: float = floor(x / _tileMap.tile_set.tile_size.x)
	var tile_y: float = floor(y / _tileMap.tile_set.tile_size.y)
	var cell: TileData = _tileMap.get_cell_tile_data(1, Vector2i(tile_x, tile_y))
	
	if (cell == null):
		return false
	
	return cell.get_custom_data("name") == "Wall"

func get_box(x: int, y: int) -> Node:
	var tile_x: float = floor(x / _tileMap.tile_set.tile_size.x)
	var tile_y: float = floor(y / _tileMap.tile_set.tile_size.y)
	for box in boxes:
		var box_x: float = floor(box.position.x / _tileMap.tile_set.tile_size.x)
		var box_y: float = floor(box.position.y / _tileMap.tile_set.tile_size.y)
		if (box_x == tile_x && box_y == tile_y):
			return box
	
	return null
	
func get_valid_box_count() -> int:
	var count: int = 0
	for box in boxes:
		var tile_x: float = floor(box.position.x / _tileMap.tile_set.tile_size.x)
		var tile_y: float = floor(box.position.y / _tileMap.tile_set.tile_size.y)
		var cell: TileData = _tileMap.get_cell_tile_data(1, Vector2i(tile_x, tile_y))
		if cell != null && cell.get_custom_data("name") == "Target":
			count += 1
			
	return count
	
func is_win() -> bool:
	return get_valid_box_count() == target_count
	
func goto_next_level() -> void:
	_timer.stop()
	reset_level()
	level += 1
	if !load_level(level):
		pass # Game finished
	generate_level()
	
func retry() -> void:
	reset_level()
	load_level(level)
	generate_level()
	
func goto_editor() -> void:
	get_tree().change_scene_to_file('res://editor.tscn')
