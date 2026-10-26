extends Node

#var piece_bitboard:Array # TODO: multiple bitboards for terrain, obstacles, etc.
@onready var player_pieces_total_value:int = 0
@onready var opponent_pieces_total_value:int = 0

# References
@onready var turn_manager = $"../TurnManager"
@onready var visuals = $"../Visuals"


func setup(game_state:GameState):
	add_piece(game_state, Vector2(5,7), true)
	add_piece(game_state,Vector2(3,3), false)


func add_piece(game_state:GameState, new_pos:Vector2, player_owned:bool):
	var piece_data:PieceData = PieceData.new()
	piece_data.player_owned = player_owned
	generate_moves(game_state,piece_data)
	if !player_owned:
		piece_data.value *= -1

	var overlap = place_piece(game_state.board, piece_data, new_pos)
	
	if overlap:
		push_warning("WARNING: Piece ", overlap.name, "removed when placing piece ", piece_data)


# Remove a piece from the board and turn order and add it to the dead list
func kill_piece(game_state:GameState, piece:PieceData):
	var piece_idx = game_state.board.find(piece)
	game_state.board[piece_idx] = null
	game_state.turn_order.erase(piece)
	game_state.dead_pieces.append(piece)
	visuals.erase_piece(piece)


func get_player_pieces_value():
	return player_pieces_total_value


func get_opponent_pieces_value():
	return opponent_pieces_total_value


func place_piece(board:Array, piece:PieceData, vec:Vector2)->PieceData:
	var idx = Utilities.vector_to_grid(vec)
	var overlap = board[idx]
	board[idx] = piece
	piece.index = idx
	return overlap


# Move piece given a game state
func move_piece(board:Array, piece:PieceData, move:Vector2):
	var return_piece:PieceData
	var idx = piece.index
	var move_pos = Utilities.grid_to_vector(idx) + move
	var new_idx = Utilities.vector_to_grid(move_pos)
	var overlap = board[new_idx]
	if overlap:
		return_piece = overlap
	board[idx] = null
	board[new_idx] = piece
	piece.index = new_idx

	return return_piece


func move_piece_to(board:Array, piece:PieceData, move_pos_final:Vector2, is_sim:bool = false):
	var return_piece
	var idx = piece.index
	var new_idx = Utilities.vector_to_grid(move_pos_final)
	var overlap = board[new_idx]
	if overlap:
		return_piece = overlap
	board[idx] = null
	board[new_idx] = piece
	piece.index = new_idx

	return return_piece


func move_piece_to_idx(board:Array, piece:PieceData, new_idx:int):
	var return_piece:PieceData
	var overlap = board[new_idx]
	if overlap:
		return_piece = overlap
	board[piece.index] = null
	board[new_idx] = piece
	piece.index = new_idx

	return return_piece

# Generates all possible moves for a given piece
#	TODO: generate moves of a given type
#	TODO: calculate in index
func generate_moves(state:GameState, data:PieceData):
	var possible_moves:Array
	possible_moves.resize(state.board.size())
	for i in state.board.size():
		var tile_possible_moves:Array
		var vec = Utilities.grid_to_vector(i)
		for move in data.base_moves:
			var move_vec = vec + move
			if Utilities.is_in_bounds(move_vec):
				var idx_move:int = Utilities.vector_to_grid(move_vec)
				tile_possible_moves.append(idx_move)
		possible_moves[i] = tile_possible_moves
	data.possible_moves = possible_moves
