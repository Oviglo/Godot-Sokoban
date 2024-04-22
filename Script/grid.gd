extends Game

func _draw() -> void:
	draw_grid()

func draw_grid() -> void:
	for x: int in MAP_WIDTH + 1:
		draw_dashed_line(Vector2(x * TILE_SIZE, 0), Vector2(x * TILE_SIZE, MAP_HEIGHT * TILE_SIZE), Color.DARK_MAGENTA, 1.0, 1.0)
		
	for y: int in MAP_HEIGHT + 1:
		draw_dashed_line(Vector2(0, y * TILE_SIZE), Vector2(MAP_WIDTH * TILE_SIZE, y * TILE_SIZE), Color.DARK_MAGENTA, 1.0, 1.0)
