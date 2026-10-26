class_name GameState 
extends Resource

var board:Array
var turn_order:Array
var dead_pieces:Array


@export var default_board_vals:Array = [
	10, 10, 10, 10, 10, 10, 10, 10,
	10, 15, 15, 15, 15, 15, 15, 10,
	10, 15, 25, 25, 25, 25, 15, 10,
	10, 15, 25, 35, 35, 25, 15, 10,
	10, 15, 25, 35, 35, 25, 15, 10,
	10, 15, 25, 25, 25, 25, 15, 10,
	10, 15, 15, 15, 15, 15, 15, 10,
	10, 10, 10, 10, 10, 10, 10, 10,]

# Setup the game state with a board and turn order
func _init(new_board:Array, new_turn_order:Array)->void:
	board = new_board
	turn_order = new_turn_order


# Make a full copy of the game state object
#	This includes a unique copy of board, turn order, and pieces
func make_copy()->GameState:
	# Copy game board objects and turn order
	var new_board:Array
	new_board.resize(board.size())
	var new_turn_order:Array
	new_turn_order.resize(turn_order.size())
	
	for i in board.size():
		var tile = board[i]
		if tile is PieceData:
			var new_tile = PieceData.new(tile.index, tile.value, tile.player_owned, tile.possible_moves)
			new_board[i] = new_tile # Add to new board
			new_turn_order[turn_order.find(tile)] = new_tile

	var new_game_state:GameState = GameState.new(new_board,new_turn_order)
	return new_game_state


## Rotate the turn order normally
#func progress_turn_order(changing_turn_order:Array):
	#var first = changing_turn_order.pop_front()
	#changing_turn_order.append(first)
#
#
#func get_next_piece()->Knight:
	#return turn_order[0]
#
## Move piece by the move, returns an overlapped piece
#func move_piece(piece, move)->Knight:
	#var return_piece:Knight
	#var idx = board.find(piece)
	#var move_pos = Utilities.grid_to_vector(idx) + move
	#var new_idx = Utilities.vector_to_grid(move_pos)
	#var overlap = check_for_overlaps(new_idx)
	#if overlap:
		#return_piece = overlap
		#board[new_idx] = piece
	#return return_piece
#
#
#func check_for_overlaps(new_idx)->bool:
	#return board[new_idx]
