extends Node

@onready var current_available_id:int = 1

# References
@onready var game_loop_manager = $"../GameLoopManager"
@onready var visuals = $"../Visuals"


func setup(game_state:GameState, move_data:MoveData):
	# game_State, move_data, new pos, health, attack, ability, player owned
	#add_piece(game_state, move_data, Vector2(5,5), 3, 1, 1, false)
	#add_piece(game_state, move_data, Vector2(3,6), 3, 1, 1, false)
	#add_piece(game_state, move_data, Vector2(3,7), 3, 1, 1, false)
	add_piece(game_state, move_data, Vector2(7,4), 3, 1, 1, false)
	add_piece(game_state, move_data, Vector2(3,4), 5, 3, 1, true)

	
	setup_turn_order(game_state)

# TODO: maybe these are stored in a file
func add_piece(game_state:GameState, move_data:MoveData, 
				new_pos:Vector2, new_health:int, 
				new_attack_damage:int, ability:int, player_owned:bool):
	var new_index:int = Utilities.vector_to_index(new_pos)
	
	if game_state.piece_id[new_index] != 0:
		push_warning("WARNING: Trying to place piece at index ", new_index, " but something is there already")
		return # Array location is already taken

	game_state.piece_id[new_index] = create_piece_id()
	game_state.type[new_index] = 1
	game_state.values[new_index] = 500 * (-1 if player_owned else 1)
	game_state.health[new_index] = new_health
	game_state.attack_damage[new_index] = new_attack_damage
	game_state.num_moves[new_index] = 1
	game_state.num_actions[new_index] = 1
	game_state.passive_abilities[new_index] = ability


	move_data.generate_moves(game_state.piece_id.size(), game_state.type[new_index])
	move_data.generate_attacks(game_state.piece_id.size(), game_state.type[new_index])



func setup_turn_order(game_state:GameState):
	game_state.turn_order.clear()
	# TODO: Assemble turn order based off piece speed
	for idx in game_state.piece_id.size():
		if game_state.piece_id[idx] != 0:
			game_state.turn_order.append(idx)


func create_piece_id():
	var new_id = current_available_id
	current_available_id += 1
	return new_id


# Remove a piece from the board and turn order and add it to the dead list
func kill_piece(game_state:GameState, idx:int):
	game_state.turn_order.remove_at(game_state.turn_order.find(idx))
	game_state.health[idx] = 0
	game_state.num_actions[idx] = 0
	game_state.num_moves[idx] = 0
	game_state.passive_abilities[idx] = 0
	game_state.type[idx] = 0
	game_state.values[idx] = 0
	game_state.attack_damage[idx] = 0
	#TODO: Store dead piece info
	game_state.piece_id[idx] = 0


func place_piece(board:Array, piece:PieceData, vec:Vector2)->PieceData:
	var idx = Utilities.vector_to_index(vec)
	var overlap = board[idx]
	board[idx] = piece
	piece.index = idx
	return overlap


func move_piece_to_idx(game_state:GameState, current_idx:int, new_idx:int, is_sim:bool = true):
	var force_move_again = false
	
	if current_idx == new_idx: # No need to move
		return force_move_again
	
	var overlap = game_state.piece_id[new_idx]
	if overlap != 0:
		attack_piece(game_state, current_idx, new_idx, true, is_sim)
		if game_state.passive_abilities[current_idx] == 1:
			force_move_again = true
			return force_move_again
		else:
			pass # knockback maybe

	
	
	# Set new index values 
	game_state.health[new_idx] = game_state.health[current_idx]
	game_state.attack_damage[new_idx] = game_state.attack_damage[current_idx]
	game_state.num_actions[new_idx] = game_state.num_actions[current_idx]
	game_state.num_moves[new_idx] = game_state.num_moves[current_idx]
	game_state.passive_abilities[new_idx] = game_state.passive_abilities[current_idx]
	game_state.piece_id[new_idx] = game_state.piece_id[current_idx]
	game_state.type[new_idx] = game_state.type[current_idx]
	game_state.values[new_idx] = game_state.values[current_idx]

	# Set old index values to zero
	game_state.health[current_idx] = 0
	game_state.attack_damage[current_idx] = 0
	game_state.num_moves[current_idx] = 0
	game_state.num_actions[current_idx] = 0
	game_state.passive_abilities[current_idx] = 0
	game_state.piece_id[current_idx] = 0
	game_state.type[current_idx] = 0
	game_state.values[current_idx] = 0

	# Replace the turn order's index 
	game_state.turn_order[0] = new_idx
	
	return force_move_again


func attack_piece(game_state:GameState, attacker_idx:int, defender_idx:int,
				  is_move_attack:bool, is_sim:bool = true):
	if attacker_idx == defender_idx:
		return
	game_state.health[defender_idx] -= game_state.attack_damage[attacker_idx]

	if game_state.health[defender_idx] <= 0:
		var piece_id = game_state.piece_id[defender_idx]
		kill_piece(game_state, defender_idx)
		if !is_sim:
			visuals.erase_piece(piece_id)



'''
Executes a move chain on a given game state
Returns the final index of the moving piece
'''
func execute_move_chain(chain:Array, game_state_in:GameState, idx:int, is_sim:bool = true):
	var end_idx = idx
	for i in range(0, chain.size(), 2):
		if chain[i] == 0: # Move action
			if chain[i+1] != -1:
				var move_again = move_piece_to_idx(game_state_in, idx, chain[i+1], is_sim)
				if !move_again: # If moving again, keep the old index
					end_idx = chain[i+1]
				
		if chain[i] == 1: # Attack action
			if (game_state_in.health[chain[i+1]] > 0 and chain[i+1] != idx): # Is attack viable?
				attack_piece(game_state_in,idx, chain[i+1], false, is_sim)
			else:
				chain[i+1] = -1
		if chain[i] == 2: # Knight double jump action
			move_piece_to_idx(game_state_in, idx, chain[i+1], is_sim)
			end_idx = game_state_in.turn_order[0]
	return end_idx
