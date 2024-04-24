extends Game

@onready var _cursor := $Cursor
@onready var _grid := $Grid
@onready var _save_btn := $Control/PanelContainer/MarginContainer/VBoxContainer/ButtonSave
@onready var _play_btn := $Control/PanelContainer/MarginContainer/VBoxContainer/ButtonPlay
@onready var _level_select := $Control/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/SpinLevel
@onready var _prev_btn := $Control/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/ButtonItemPrev
@onready var _next_btn := $Control/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/ButtonItemNext
@onready var _selected_item_view := $Control/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/SelectedItemView

enum TYPE {EMPTY, WALL, BOX, PLAYER, TARGET}

var selected_tile: TYPE = TYPE.WALL

func _ready() -> void:
	load_level(level)
	
	_save_btn.pressed.connect(self.save_button_pressed)
	_level_select.value_changed.connect(self.change_level)
	_play_btn.pressed.connect(self.play_game)
	_prev_btn.pressed.connect(self.select_prev)
	_next_btn.pressed.connect(self.select_next)
	
	draw_selected_tile()

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
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) || Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		var mouse_x: int = get_viewport().get_mouse_position().x
		var mouse_y: int = get_viewport().get_mouse_position().y
		
		if (mouse_x < (MAP_WIDTH * TILE_SIZE) && mouse_y < (MAP_HEIGHT * TILE_SIZE)):
			_cursor.position.x = floor(get_viewport().get_mouse_position().x / TILE_SIZE) * TILE_SIZE
			_cursor.position.y = floor(get_viewport().get_mouse_position().y / TILE_SIZE) * TILE_SIZE
			
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			create_tile(cursor_position, TYPE.EMPTY)			
		elif Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			create_tile(cursor_position, selected_tile)

func draw_selected_tile() -> void:
	var texture: Texture2D = _tileMap.get_tileset().get_source(0).get_runtime_texture()
	var region: Rect2i = _tileMap.get_tileset().get_source(0).get_runtime_tile_texture_region(Vector2i(selected_tile, 0), 0)
	var atlas_texture := AtlasTexture.new()
	atlas_texture.set_atlas(texture)
	atlas_texture.set_region(region)
	_selected_item_view.set_texture(atlas_texture)
	
func select_prev() -> void:
	selected_tile -= 1
	if selected_tile < 1:
		selected_tile = 4
		
	draw_selected_tile()
		
func select_next() -> void:
	selected_tile += 1
	if selected_tile > 4:
		selected_tile = 1
	
	draw_selected_tile()

func save_button_pressed() -> void:
	save_level(level)
	
func change_level(value: float) -> void:
	level = int(value)
	load_level(level)
		
func create_tile(position: Vector2, type: TYPE) -> void:
	if type == TYPE.EMPTY:
		_tileMap.set_cell(1, position, 0)
	else:
		_tileMap.set_cell(1, position, 0, Vector2i(float(type), 0))
	pass
	
func play_game() -> void:
	get_tree().change_scene_to_file('res://level.tscn')

