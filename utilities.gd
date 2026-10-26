extends Node

var tile_size:int
var board_origin:Vector2
var board_scale:int


func set_utilities_constants(new_tile_size:int, new_board_origin:Vector2, new_board_scale:int):
	tile_size = new_tile_size
	board_origin = new_board_origin
	board_scale = new_board_scale


# Determine if point is within the board bounds
func is_in_bounds(point:Vector2):
	# TODO: use bounds provided by board
	return ((point[0] < 8 and point[0] >= 0) and
			(point[1] < 8 and point[1] >= 0))


# Coverts grid (1-D Array) coords to global (Vector2) coords
func grid_to_global(idx:int):
	var grid_coords:Vector2
	grid_coords = grid_to_vector(idx)
	var x = (board_origin[0] + (grid_coords[0] * tile_size * board_scale))
	var y = (board_origin[1] - (grid_coords[1] * tile_size * board_scale))
	return Vector2(x,y)


# Convert global (Vector2) coords to grid (1-D Array) coords
func global_to_grid(coords:Vector2):
	return vector_to_grid(global_to_vector(coords))


# Convert grid (1-D Array) coords to global (Vector2) coords
func grid_to_vector(idx:int):
	var grid_coords:Vector2
	@warning_ignore("integer_division")
	grid_coords[1] = int(idx / 8)
	grid_coords[0] = idx % 8
	return grid_coords

# Convert Vector (Vector2) coords to grid (1-D Array) coords
func vector_to_grid(coords:Vector2):
	return coords[0] + coords[1] * 8

func global_to_vector(coords:Vector2):
	var vec = ((coords - board_origin) / (tile_size * board_scale))
	vec[1] *= -1
	return vec.round()

func vector_to_global(coords:Vector2):
	var x = board_origin[0] + (coords[0] * tile_size * board_scale)
	var y = board_origin[1] - (coords[1] * tile_size * board_scale)
	return Vector2(x,y)
