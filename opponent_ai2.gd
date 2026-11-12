extends Node

var move_dictionary:Dictionary
var distance_scoring_dictionary:Dictionary
var attack_dictionary:Dictionary
var tile_vals_dictionary:Dictionary

var best_game_states:Array = []
var best_score:int

@onready var board_manager = $"../../BoardManager"
@onready var game_loop_manager = $"../../GameLoopManager"


func get_best_move(game_state:GameState, move_data_in:MoveData):
	move_dictionary = move_data_in.piece_move_dictionary.duplicate()
	distance_scoring_dictionary = move_data_in.distance_scoring_dictionary.duplicate()
	attack_dictionary = move_data_in.piece_attacks_dictionary.duplicate()
	tile_vals_dictionary = move_data_in.tile_values_dictionary.duplicate()

	var idx = game_state.turn_order[0]
	var type = game_state.type[idx]
	var num_moves = game_state.num_moves[idx]
	var num_attacks = game_state.num_actions[idx]
	var depth = 1
	best_score = -9223372036854775808 # REEEEALLY SMOL


	if num_moves > 0: # Simulate moves
		for move in move_dictionary[type][idx]:
			var new_game_state = game_state.copy()
			var move_again = board_manager.move_piece_to_idx(new_game_state, idx, move, true, false)
	
			# double jump?
			if move_again && (game_state.passive_abilities[idx] == 1):
				for double_move in move_dictionary[type][move]:
					var new_game_state_two = new_game_state.copy()
					# TODO: while loop to check for multiple double jumps
					var move_again_two = board_manager.move_piece_to_idx(new_game_state_two, move, double_move, true, true)
					simulate_turn(new_game_state_two, depth, double_move, type, num_moves-1, num_attacks, true, false)
			else:
				simulate_turn(new_game_state, depth, move, type, num_moves-1, num_attacks, true, false)
		# No move condition
		var new_game_state = game_state.copy()
		board_manager.move_piece_to_idx(new_game_state, idx, idx, true, false)
		simulate_turn(new_game_state, depth, idx, type, num_moves-1, num_attacks, true, false)

	if num_attacks > 0: # simulate attacks
		for attack in attack_dictionary[type][idx]:
			if game_state.piece_id[attack] == 0:
				continue # attack does nothing
			var new_game_state = game_state.copy()
			board_manager.attack_piece(new_game_state, idx, attack, false, true)
			simulate_turn(new_game_state, depth, idx, type, num_moves, num_attacks-1, true, false)

		var new_game_state = game_state.copy()
		board_manager.attack_piece(new_game_state, idx, idx, false, true)
		simulate_turn(new_game_state, depth, idx, type, num_moves, num_attacks-1, true, false)

	## pick a random best chain, or the best chain if there's only one
	var choice = best_game_states.pick_random()
	return choice




func simulate_turn(game_state:GameState, depth:int, idx:int, type:int, num_moves:int,
				   num_attacks:int, save_move_chain:bool, purge_branch:bool):
	if purge_branch:
		return -INF # Branch sucks, kill it

	var save_chain = save_move_chain
	
	# "shared move-attacks" passive ability
	if game_state.passive_abilities[idx] == 2: 
		var lower = min(num_moves, num_attacks)
		num_moves = lower
		num_attacks = lower
	
	# Can the piece perform any actions?
	if num_moves == 0 and num_attacks == 0:
		depth -= 1
		if depth == 0:
			return score_board(game_state)
		else:
			# TODO: setup next piece's moves
			save_chain = false # stop saving the chain after the first depth

	if num_moves > 0: # Simulate moves
		for move in move_dictionary[type][idx]:
			var new_game_state = game_state.copy()
			var move_again = board_manager.move_piece_to_idx(new_game_state, idx, move, true, false)
			
			# double jump?
			if move_again && (game_state.passive_abilities[idx] == 1):
				for double_move in move_dictionary[type][move]:
					var new_game_state_two = new_game_state.copy()
					# TODO: while loop to check for multiple double jumps
					var move_again_two = board_manager.move_piece_to_idx(new_game_state_two, move, double_move, true, true)
					return simulate_turn(new_game_state_two, depth, double_move, type, num_moves-1, num_attacks, save_chain, false)
			else:
				return simulate_turn(new_game_state, depth, move, type, num_moves-1, num_attacks, save_chain, false)
		# No move condition
		var new_game_state = game_state.copy()
		board_manager.move_piece_to_idx(new_game_state, idx, idx, true, false)
		return simulate_turn(new_game_state, depth, idx, type, num_moves-1, num_attacks, save_chain, false)

	if num_attacks > 0: # simulate attacks
		for attack in attack_dictionary[type][idx]:
			if game_state.piece_id[attack] == 0:
				continue # attack does nothing
			var new_game_state = game_state.copy()
			board_manager.attack_piece(new_game_state, idx, attack, false, true)
			return simulate_turn(new_game_state, depth, idx, type, num_moves, num_attacks-1, save_chain, false)

		var new_game_state = game_state.copy()
		board_manager.attack_piece(new_game_state, idx, idx, false, true)
		return simulate_turn(new_game_state, depth, idx, type, num_moves, num_attacks-1, save_chain, false)



## Gives the current board a score
# Score is calculated as:
# 	value * health + proximity
func score_board(game_state:GameState):
	var board_val:int = 0
	var player_count:Array
	var opponent_count:Array
	
	# Gather player and opponent indexes
	for i in game_state.values.size():
		var val = game_state.values[i]
		if val != 0:
			board_val += val * game_state.health[i]
			if game_state.values[i] < 0:
				player_count.append(i) 
			else:
				opponent_count.append(i) 
	
	# Proximity score
	for i in game_state.values.size():
		var val = game_state.values[i]
		if val < 0: # Player piece
			var player_pos = Utilities.index_to_vector(i)
			var player_type = game_state.type[i]
			for opp_idx in opponent_count: # loop through enemies for proximity
				var opp_pos = Utilities.index_to_vector(opp_idx)
				var dist_to_player:int = player_pos.distance_to(opp_pos)
				board_val += distance_scoring_dictionary[player_type][dist_to_player]

		elif val > 0: # Opponent piece
			var enemy_pos = Utilities.index_to_vector(i)
			var opp_type = game_state.type[i]
			for opp_idx in opponent_count: # loop through enemies for proximity
				var opp_pos = Utilities.index_to_vector(opp_idx)
				var dist_to_opp:int = enemy_pos.distance_to(opp_pos)
				board_val += distance_scoring_dictionary[opp_type][dist_to_opp]

	# Compare scores
	if (board_val >= best_score): # is our board high scoring?
		if board_val > best_score:
			best_game_states.clear() # If we hit an -inf, clear best move list
			best_score = board_val
			best_game_states.append(game_state)
		print(game_state.move_chain, " scores ", board_val)
	return
