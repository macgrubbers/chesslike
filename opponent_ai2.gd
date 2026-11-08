extends Node

var move_dictionary:Dictionary
var attack_dictionary:Dictionary
var tile_vals_dictionary:Dictionary

var move_chains:Array
var num_combos:int = 0
var bad_combos:int = 0

@onready var board_manager = $"../../BoardManager"
@onready var game_loop_manager = $"../../GameLoopManager"


## Gives the current board a score
func score_board(state:GameState):
	var board_val:int = 0
	for i in state.values.size():
		if state.piece_id[i] != 0:
			var tile_sign = (-1 if state.values[i] < 0 else 1)
			board_val += ((state.values[i]*state.health[i]) + (tile_vals_dictionary[state.type[i]][i]) * tile_sign)
	return board_val

'''
Calculates best possible move
Creates "move chains", a sequence of possible moves and attacks
Move chains are then executed and scored
'''
func get_best_move(game_state_in:GameState, move_data_in:MoveData):
	move_dictionary = move_data_in.piece_move_dictionary.duplicate()
	attack_dictionary = move_data_in.piece_attacks_dictionary.duplicate()
	tile_vals_dictionary = move_data_in.tile_values_dictionary.duplicate()

	var piece_idx = game_state_in.turn_order[0]
	var piece_type = game_state_in.type[piece_idx]
	var num_moves = game_state_in.num_moves[piece_idx]
	var num_attacks = game_state_in.num_actions[piece_idx]
	move_chains.clear()
	assemble_move_chain(game_state_in, piece_idx, piece_type, num_moves, num_attacks, [], true)
	print(move_chains.size(), " total good chains")
	print(bad_combos, " bad chains pruned")
	
	
	var best_val = -10000000
	var best_chains:Array
	for i in move_chains.size():
		var new_game_state = game_state_in.copy()
		board_manager.execute_move_chain(move_chains[i], new_game_state, piece_idx)

		var board_val = score_board(new_game_state)
		if (board_val >= best_val): # is our board high scoring?
			if board_val > best_val:
				best_chains.clear() # If we hit an -inf, clear best move list
			best_val = board_val
			best_chains.append(move_chains[i])
		print(move_chains[i], " scores ", board_val)
	var choice = best_chains.pick_random()
	print(best_chains.size(), " options")
	print(choice, " chosen")
	return choice


## Assembles all possible move chains given n moves and m actions
# TODO: Filter only attackable squares
# TODO: Maybe don't create a chain and just iterate through all of em
# TODO: would be easier to just make the chain as we iterate
func assemble_move_chain(game_state:GameState, idx:int, type:int, num_moves:int, num_attacks:int, chain:Array, chain_ok:bool):
	var is_chain_ok = chain_ok
	if num_moves == 0 and num_attacks == 0:
		if is_chain_ok:
			move_chains.append(chain)
			num_combos += 1
		else:
			bad_combos += 1
		return

	if num_moves > 0:
		for move in move_dictionary[type][idx]:
			var new_chain = chain.duplicate()
			new_chain.append(0)
			new_chain.append(move)
			
			 # simulate knight double jump
			if game_state.health[move] > 0:
				for double_move in move_dictionary[type][move]:
					var double_move_chain = new_chain.duplicate()
					double_move_chain.append(2)
					double_move_chain.append(double_move)
					assemble_move_chain(game_state, double_move, type, num_moves-1, num_attacks, double_move_chain, is_chain_ok)
			else:
				assemble_move_chain(game_state, move, type, num_moves-1, num_attacks, new_chain, is_chain_ok)
		# No move condition
		var new_chain = chain.duplicate()
		new_chain.append(0)
		new_chain.append(-1)
		assemble_move_chain(game_state, idx, type, num_moves-1, num_attacks, new_chain, is_chain_ok)

	if num_attacks > 0:
		for attack in attack_dictionary[type][idx]:
			var new_chain = chain.duplicate()
			new_chain.append(1)
			new_chain.append(attack)
			if game_state.health[attack] == 0: # Prune chains that have useless attacks
				assemble_move_chain(game_state, idx, type, num_moves, num_attacks-1, new_chain, false)
			else:
				assemble_move_chain(game_state, idx, type, num_moves, num_attacks-1, new_chain, is_chain_ok)
		# No attack condition
		var new_chain = chain.duplicate()
		new_chain.append(1)
		new_chain.append(-1)
		assemble_move_chain(game_state, idx, type, num_moves, num_attacks-1, new_chain, is_chain_ok)
