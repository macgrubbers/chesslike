extends Node

var move_dictionary:Dictionary
var tile_vals_dictionary:Dictionary

@onready var board_manager = $"../../BoardManager"
@onready var game_loop_manager = $"../../GameLoopManager"


# Call this from your main game logic to get the best move
func get_best_move(game_state_in:GameState, move_data_in:MoveData, max_depth: int) -> int:
	move_dictionary = move_data_in.piece_move_dictionary.duplicate()
	tile_vals_dictionary = move_data_in.tile_values_dictionary.duplicate()
	var best_move: Array[int]
	var best_val: float = INF
	var current_piece_idx:int = game_state_in.turn_order[0]
	var current_piece_type:int = game_state_in.type[current_piece_idx]
	
	# Get all valid moves for the playing piece
	for move in move_dictionary[current_piece_type][current_piece_idx]:
		var game_state_copy = game_state_in.copy()
		# 1. Create a simulated board state
		# TODO: move via index maybe
		board_manager.move_piece_to_idx(game_state_copy, current_piece_idx, move)

		# Evaluate the branch
		var move_val = minimax(game_state_copy, max_depth - 1, -INF, INF, true)

		# Track highest score option(s)
		if move_val <= best_val and move_val != INF:
			if move_val < best_val:
				best_move.clear() # If we hit an -inf, clear best move list
			best_val = move_val
			best_move.append(move) # If we have ties, we pick a random
		print("Move ", move, " = ", move_val)

	return best_move.pick_random()


# Minimax with alpha-beta pruning
func minimax(game_state_in:GameState, depth: int, alpha: float, beta: float, is_maximizing: bool) -> float:
	game_loop_manager.progress_turn_order(game_state_in.turn_order)

	# Check if leaf node
	var win_condition:int = sim_check_game_over(game_state_in)
	if win_condition != 0:
		return INF * win_condition

	if depth == 0:
		return score_board(game_state_in)

	var current_piece_idx:int = game_state_in.turn_order[0]

	if is_maximizing:
		var max_eval: float = -INF
		for move in move_dictionary[game_state_in.type[current_piece_idx]][current_piece_idx]:

			var game_state_copy:GameState = game_state_in.copy()
			board_manager.move_piece_to_idx(game_state_copy, current_piece_idx, move)
			var move_val = minimax(game_state_copy, depth - 1, alpha, beta, false)
			
			max_eval = max(max_eval, move_val)
			
			# Alpha-Beta Pruning: Chop off unnecessary tree branches
			alpha = max(alpha, move_val)
			if beta <= alpha:
				break 
		return max_eval
		
	else: # Minimizing
		var min_eval: float = INF
		for move in move_dictionary[game_state_in.type[current_piece_idx]][current_piece_idx]:
			
			var game_state_copy:GameState = game_state_in.copy()
			board_manager.move_piece_to_idx(game_state_copy, current_piece_idx, move)
			var move_val = minimax(game_state_copy, depth - 1, alpha, beta, true)

			min_eval = min(min_eval, move_val)
			
			# Alpha-Beta Pruning
			beta = min(beta, move_val)
			if beta <= alpha:
				break
		return min_eval


# Check for win conditions
func sim_check_game_over(game_state:GameState):
	var winner_int:int = 0
	var player_piece_count:int = 0
	var opponent_piece_count:int = 0
	
	for tile in game_state.values:
		if tile < 0:
			player_piece_count += 1
		elif tile > 0:
			opponent_piece_count += 1

	if player_piece_count == 0:
		winner_int = -1
	elif opponent_piece_count == 0:
		winner_int = 1

	return winner_int


# Gives the current board a score
func score_board(state:GameState):
	var board_val:int = 0
	for i in state.values.size():
		if state.values[i] != 0:
			board_val += (state.values[i] * tile_vals_dictionary[state.type[i]][i])
	return board_val
