class_name Game
extends Node2D

const MAP_WIDTH: int = 16
const MAP_HEIGHT: int = 11

const TILE_SIZE: int = 64

const TYPE_WALL: String = '1'
const TYPE_BOX: String = '2'
const TYPE_PLAYER: String = '3'
const TYPE_TARGET: String = '4'

var level: int = 1

@onready var _tileMap := $TileMap

func clear_level() -> void:
	for x: int in MAP_WIDTH:
		for y: int in MAP_HEIGHT:
			_tileMap.set_cell(1, Vector2i(x, y))

func load_level(number: int) -> bool:
	clear_level()
	var file: FileAccess = FileAccess.open('res://Levels/' + str(number) + '.lvl', FileAccess.READ)
	if null == file:
		return false
		
	var file_data: Array = file.get_as_text().split(',')
	for x: int in MAP_WIDTH:
		for y: int in MAP_HEIGHT:
			var pos: int = (x * MAP_HEIGHT) + y
			var data = int(file_data[pos])
			if (data != 0):
				_tileMap.set_cell(1, Vector2i(x,y), 0, Vector2i(data, 0))
				
	return true

func save_level(number: int) -> void:
	var file: FileAccess = FileAccess.open('res://Levels/' + str(number) + '.lvl', FileAccess.WRITE)
	for x: int in MAP_WIDTH:
		for y: int in MAP_HEIGHT:
			var tile_data: TileData = _tileMap.get_cell_tile_data(1, Vector2i(x, y))
			if tile_data == null:
				file.store_string('0,')
				continue
			
			var name: String = tile_data.get_custom_data('name')
			var id: String = '0'
			match name:
				"Box":
					id = TYPE_BOX
				"Wall":
					id = TYPE_WALL
				"Player":
					id = TYPE_PLAYER
				"Target":
					id = TYPE_TARGET
					
			file.store_string(id + ',')
