extends Node

@onready var piece_manager = $"../../PieceManager"
@onready var turn_manager = $"../../TurnManager"


# Call this from your main game logic to get the best move
func get_best_move(game_state:GameState, max_depth: int) -> int:
	var best_move: Array[int]
	var best_val: float = INF
	var current_piece:PieceData = game_state.turn_order[0]
	print("Current piece at ", Utilities.grid_to_vector(current_piece.index))
	
	# Get all valid moves for the playing piece
	for move:int in current_piece.possible_moves[current_piece.index]:
		var game_state_copy = game_state.make_copy()
		current_piece = game_state_copy.turn_order[0]
		# 1. Create a simulated board state
		# TODO: move via index maybe
		var overlap_piece = piece_manager.move_piece_to_idx(game_state_copy.board, current_piece, move)
		if overlap_piece: # Damage the piece, or kill it in this case
			piece_manager.kill_piece(game_state_copy, overlap_piece)
		
		# Evaluate this move branch
		# We should ALWAYS be minimizing here first, as the predicting piece should be the computer
		var move_val = minimax(game_state_copy, max_depth - 1, -INF, INF, true)
		
		# Track highest score option(s)
		if move_val <= best_val and move_val != INF:
			if move_val < best_val:
				best_move.clear() # If we hit an -inf, clear best move list
			best_val = move_val
			best_move.append(move) # If we have ties, we pick a random
		print("Move ", move, " = ", move_val)
	print("-----------------------")
	return best_move.pick_random()

# Minimax with alpha-beta pruning
func minimax(game_state:GameState, depth: int, alpha: float, beta: float, is_maximizing: bool) -> float:
	var game_state_copy:GameState = game_state.make_copy()
	turn_manager.progress_turn_order(game_state_copy.turn_order)
	var current_piece:PieceData = game_state_copy.turn_order[0]
	
	# Leaf node check: Stop if game is over or we reached our max tree depth
	var win_condition:int = sim_check_game_over(game_state_copy)
	if win_condition != 0:
		return INF * win_condition

	if depth == 0:
		return score_board(game_state_copy)

	if is_maximizing:
		var max_eval: float = -INF
		for move in current_piece.possible_moves[current_piece.index]:
			var overlap_piece = piece_manager.move_piece_to_idx(game_state_copy.board, current_piece, move)
			if overlap_piece: # Damage the piece, or kill it in this case
				piece_manager.kill_piece(game_state_copy, overlap_piece)
			
			var move_val = minimax(game_state_copy, depth - 1, alpha, beta, false)
			max_eval = max(max_eval, move_val)
			
			# Alpha-Beta Pruning: Chop off unnecessary tree branches
			alpha = max(alpha, move_val)
			if beta <= alpha:
				break 
		return max_eval
		
	else: # Minimizing player (the opponent)
		var min_eval: float = INF
		for move in current_piece.possible_moves[current_piece.index]:
			#var sim_board = make_sim_board(board)
			var overlap_piece = piece_manager.move_piece_to_idx(game_state_copy.board, current_piece, move)
			if overlap_piece: # Damage the piece, or kill it in this case
				piece_manager.kill_piece(game_state_copy, overlap_piece)

			var move_val = minimax(game_state_copy, depth - 1, alpha, beta, true)

			min_eval = min(min_eval, move_val)
			
			# Alpha-Beta Pruning
			beta = min(beta, move_val)
			if beta <= alpha:
				break
		return min_eval


# Make a simulated board
# This includes simulated pieces too
func setup_sim(board:Array, sim_board:Array, turn_order:Array, sim_turn_order:Array):
	sim_board.resize(board.size())
	sim_turn_order.resize(turn_order.size())
	for i in board.size():
		var piece = board[i]
		if piece is PieceData:
			var sim_piece = piece.duplicate()
			get_tree().current_scene.add_child(sim_piece)
			sim_board[i] = sim_piece
			sim_turn_order[turn_order.find(piece)] = sim_piece


# Check for win conditions
func sim_check_game_over(game_state:GameState):
	var winner_int:int = 0
	var player_piece_count:int = 0
	var opponent_piece_count:int = 0
	
	for tile in game_state.board:
		if tile is PieceData:
			if tile.player_owned:
				player_piece_count += 1
			else:
				opponent_piece_count += 1

	if player_piece_count == 0:
		winner_int = -1
	elif opponent_piece_count == 0:
		winner_int = 1

	return winner_int


func score_board(game_state:GameState):
	var board_val:int = 0
	for i in game_state.board.size():
		var piece = game_state.board[i]
		if piece is PieceData:
			var flip_sign = -1
			if piece.player_owned:
				flip_sign = 1
			var tile_val = game_state.default_board_vals[i] * flip_sign
			board_val += (piece.value + tile_val)

	return board_val
