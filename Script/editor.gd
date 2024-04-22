extends Game

@onready var _cursor := $Cursor
@onready var _grid := $Grid
@onready var _saveBtn := $Control/PanelContainer/MarginContainer/VBoxContainer/ButtonSave
@onready var _playBtn := $Control/PanelContainer/MarginContainer/VBoxContainer/ButtonPlay
@onready var _levelSelect := $Control/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/SpinLevel

enum TYPE {EMPTY, WALL, BOX, PLAYER, TARGET}

func _ready() -> void:
	load_level(level)
	
	_saveBtn.pressed.connect(self.save_button_pressed)
	_levelSelect.value_changed.connect(self.change_level)
	_playBtn.pressed.connect(self.play_game)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("move_bottom") && _cursor.position.y < ((MAP_HEIGHT -1) * TILE_SIZE):
		_cursor.position.y += TILE_SIZE
	if Input.is_action_just_pressed("move_top") && _cursor.position.y > 0:
		_cursor.position.y -= TILE_SIZE
	if Input.is_action_just_pressed("move_left") && _cursor.position.x > 0:
		_cursor.position.x -= TILE_SIZE
	if Input.is_action_just_pressed("move_right") && _cursor.position.x < ((MAP_WIDTH -1) * TILE_SIZE):
		_cursor.position.x += TILE_SIZE
		
	var cursor_position: Vector2 = Vector2(_cursor.position.x / TILE_SIZE, _cursor.position.y / TILE_SIZE)
	if Input.is_key_pressed(KEY_W):
		create_tile(cursor_position, TYPE.WALL)
	if Input.is_key_pressed(KEY_P):
		create_tile(cursor_position, TYPE.PLAYER)
	if Input.is_key_pressed(KEY_B):
		create_tile(cursor_position, TYPE.BOX)
	if Input.is_key_pressed(KEY_T):
		create_tile(cursor_position, TYPE.TARGET)
	if Input.is_key_pressed(KEY_E):
		create_tile(cursor_position, TYPE.EMPTY)
	if Input.is_key_pressed(KEY_S):
		save_level(1)
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var mouse_x: int = get_viewport().get_mouse_position().x
		var mouse_y: int = get_viewport().get_mouse_position().y
		
		if (mouse_x < (MAP_WIDTH * TILE_SIZE) && mouse_y < (MAP_HEIGHT * TILE_SIZE)):
			_cursor.position.x = floor(get_viewport().get_mouse_position().x / TILE_SIZE) * TILE_SIZE
			_cursor.position.y = floor(get_viewport().get_mouse_position().y / TILE_SIZE) * TILE_SIZE
		
func save_button_pressed() -> void:
	save_level(level)
	
func change_level(value: float) -> void:
	level = int(value)
	load_level(level)
		
func create_tile(position: Vector2, type: TYPE) -> void:
	if type == TYPE.EMPTY:
		_tileMap.set_cell(1, position, 1)
	else:
		_tileMap.set_cell(1, position, 1, Vector2i(float(type), 0))
	pass
	
func play_game() -> void:
	get_tree().change_scene_to_file('res://level.tscn')

