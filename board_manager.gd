extends Node

@onready var current_available_id:int = 1

# References
@onready var game_loop_manager = $"../GameLoopManager"
@onready var visuals = $"../Visuals"


func setup(game_state:GameState, move_data:MoveData):
	# game_State, move_data, new pos, health, attack, ability, player owned
	add_piece(game_state, move_data, 3,  Vector2(5,5), 6, 2, 2, false)
	#add_piece(game_state, move_data, 2, Vector2(3,6), 3, 1, 2, false)
	#add_piece(game_state, move_data, 2, Vector2(3,7), 3, 1, 2, false)
	#add_piece(game_state, move_data, 2, Vector2(7,4), 3, 1, 2, false)
	#add_piece(game_state, move_data, 2, Vector2(7,4), 3, 1, 2, false)
	
	# PLAYER
	add_piece(game_state, move_data, 1, Vector2(3,4), 5, 2, 1, true)


	
	setup_turn_order(game_state)

# TODO: maybe these are stored in a file
func add_piece(game_state:GameState, move_data:MoveData, 
				type:int,
				new_pos:Vector2, new_health:int, 
				new_attack_damage:int, ability:int, player_owned:bool):
	var new_index:int = Utilities.vector_to_index(new_pos)
	
	if game_state.piece_id[new_index] != 0:
		push_warning("WARNING: Trying to place piece at index ", new_index, " but something is there already")
		return # Array location is already taken

	game_state.piece_id[new_index] = create_piece_id()
	game_state.type[new_index] = type
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


func move_piece_to_idx(game_state:GameState, current_idx:int, 
					   new_idx:int, is_sim:bool = true, use_temp_tile:bool = false,
					   use_chain:bool = false):
	var force_move_again = false
	
	if current_idx == new_idx and !use_temp_tile: # No need to move
		return force_move_again
	
	if use_temp_tile:
		current_idx = game_state.temp_tile[1]
	
	var overlap = game_state.piece_id[new_idx]
	if overlap != 0:
		# game_state, attacker_idx, defender_idx, is_sim, chain, use_chain
		attack_piece(game_state, current_idx, new_idx, is_sim, use_chain)

		if (game_state.passive_abilities[current_idx] == 1 or 
			game_state.temp_tile.size() > 1): # Check temp tile too
			force_move_again = true
			if game_state.temp_tile.size() == 0: # Update tile
				store_temp_piece(game_state, current_idx, new_idx)
			else: # update temp tile
				game_state.temp_tile[1] = new_idx
			return force_move_again
		else:
			var current_pos = Utilities.index_to_vector(current_idx)
			var new_pos = Utilities.index_to_vector(new_idx)
			var knockback_dir = current_pos.direction_to(new_pos).normalized()
			knockback_piece(game_state, new_idx, knockback_dir, is_sim)

	# Set new index values 
	if !use_temp_tile:
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
		game_state.turn_order[game_state.turn_order.find(current_idx)] = new_idx
	else:
		pop_temp_piece(game_state, new_idx)
	# Replace the turn order's index 
	
	return force_move_again


func attack_piece(game_state:GameState, attacker_idx:int, defender_idx:int,
				  is_sim:bool = true, use_chain:bool = false):
	if attacker_idx == defender_idx:
		return # no attacking ourselves, exit out

	var damage = game_state.attack_damage[attacker_idx]
	game_state.health[defender_idx] -= damage

	if use_chain:
		var new_segment = ["attack", attacker_idx, defender_idx, damage]
		game_state.move_chain.append(new_segment)

	if game_state.health[defender_idx] <= 0:
		var piece_id = game_state.piece_id[defender_idx]
		kill_piece(game_state, defender_idx)
		if use_chain:
			var new_segment = ["kill", defender_idx]
			game_state.move_chain.append(new_segment)
	return


func knockback_piece(game_state:GameState, idx:int, knockback_dir:Vector2, is_sim:bool):
	var final_pos:Vector2 = Utilities.index_to_vector(idx) + knockback_dir
	
	# Kill piece if out of bounds
	if !Utilities.is_in_bounds(final_pos):
		kill_piece(game_state, idx)
		return true
	
	var final_idx = Utilities.vector_to_index(final_pos)
	
	# Check if final knockback index is filled
	if game_state.piece_id[final_idx] != 0:
		return false
	
	#knockback the piece
	move_piece_to_idx(game_state, idx, final_idx, is_sim)
	return true


func store_temp_piece(game_state:GameState, current_idx:int, new_idx:int):
	game_state.temp_tile = [current_idx, new_idx, game_state.piece_id[current_idx], game_state.type[current_idx], game_state.values[current_idx],
							game_state.health[current_idx], game_state.num_moves[current_idx], game_state.num_actions[current_idx],
							game_state.passive_abilities[current_idx], game_state.attack_damage[current_idx]]
	## [current_idx, temp_idx, id, type, val, hp, #moves, #actions, passives, attack]
	game_state.piece_id[current_idx] = 0
	game_state.type[current_idx] = 0
	game_state.values[current_idx] = 0
	game_state.health[current_idx] = 0
	game_state.num_moves[current_idx] = 0
	game_state.num_actions[current_idx] = 0
	game_state.passive_abilities[current_idx] = 0
	game_state.attack_damage[current_idx] = 0


func pop_temp_piece(game_state:GameState, idx:int):
	game_state.turn_order[game_state.turn_order.find(game_state.temp_tile[0])] = idx
	game_state.piece_id[idx] = game_state.temp_tile[2]
	game_state.type[idx] = game_state.temp_tile[3]
	game_state.values[idx] = game_state.temp_tile[4]
	game_state.health[idx] = game_state.temp_tile[5]
	game_state.num_moves[idx] = game_state.temp_tile[6]
	game_state.num_actions[idx] = game_state.temp_tile[7]
	game_state.passive_abilities[idx] = game_state.temp_tile[8]
	game_state.attack_damage[idx] = game_state.temp_tile[9]
	game_state.temp_tile = []

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
				# game_state, attacker_idx, defender_idx, is_sim, chain, use_chain
				attack_piece(game_state_in,idx, chain[i+1], is_sim)
			else:
				chain[i+1] = -1
		if chain[i] == 2: # Knight double jump action
			move_piece_to_idx(game_state_in, idx, chain[i+1], is_sim, true)
			end_idx = game_state_in.turn_order[0]
	return end_idx
