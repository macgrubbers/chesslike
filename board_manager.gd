extends Node

@onready var current_available_id:int = 1

# References
@onready var game_loop_manager = $"../GameLoopManager"
@onready var visuals = $"../Visuals"


func setup(game_state:GameState, move_data:MoveData):
	add_piece(game_state, move_data, Vector2(5,5), false)
	add_piece(game_state, move_data, Vector2(3,4), true)
	#add_piece(game_state, Vector2(3,6), false)
	#add_piece(game_state, Vector2(3,7), false)
	#add_piece(game_state, Vector2(7,4), false)
	
	setup_turn_order(game_state)

# TODO: maybe these are stored in a file
func add_piece(game_state:GameState, move_data:MoveData, new_pos:Vector2, player_owned:bool):
	var new_index:int = Utilities.vector_to_index(new_pos)
	
	if game_state.piece_id[new_index] != 0:
		push_warning("WARNING: Trying to place piece at index ", new_index, " but something is there already")
		return # Array location is already taken
	
	#game_state.tile_ids[new_index]
	#game_state.terrain[new_index]
	game_state.piece_id[new_index] = create_piece_id()
	game_state.type[new_index] = 1
	game_state.values[new_index] = 500 * (-1 if player_owned else 1)
	game_state.health[new_index] = 10
	game_state.num_moves[new_index] = 1
	game_state.num_actions[new_index] = 1
	game_state.passive_abilities[new_index] = 1 << 1


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
	#TODO: Store dead piece info
	game_state.piece_id[idx] = 0


func place_piece(board:Array, piece:PieceData, vec:Vector2)->PieceData:
	var idx = Utilities.vector_to_index(vec)
	var overlap = board[idx]
	board[idx] = piece
	piece.index = idx
	return overlap


func move_piece_to_idx(game_state:GameState, current_idx:int, new_idx:int, is_sim:bool = true):
	#var force_move_again = false
	#print("Piece at ", current_idx, " simulating move to ", new_idx)
	if game_state.health[current_idx] == 0:
		print("ERROR, no piece here!!!")
	
	var overlap = game_state.health[new_idx]
	if overlap:
		attack_piece(game_state, current_idx, new_idx, true, is_sim)
	
	# Set new index values 
	game_state.health[new_idx] = game_state.health[current_idx]
	game_state.num_actions[new_idx] = game_state.num_actions[current_idx]
	game_state.num_moves[new_idx] = game_state.num_moves[current_idx]
	game_state.passive_abilities[new_idx] = game_state.passive_abilities[current_idx]
	game_state.piece_id[new_idx] = game_state.piece_id[current_idx]
	game_state.type[new_idx] = game_state.type[current_idx]
	game_state.values[new_idx] = game_state.values[current_idx]

	# Set old index values to zero
	game_state.health[current_idx] = 0
	game_state.num_actions[current_idx] = 0
	game_state.num_moves[current_idx] = 0
	game_state.passive_abilities[current_idx] = 0
	game_state.piece_id[current_idx] = 0
	game_state.type[current_idx] = 0
	game_state.values[current_idx] = 0

	# Replace the turn order's index 
	game_state.turn_order[game_state.turn_order.find(current_idx)] = new_idx



func attack_piece(game_state:GameState, attacker_idx:int, defender_idx:int,
				  is_move_attack:bool, is_sim:bool = true):
	game_state.health[defender_idx] -= 10

	if game_state.health[defender_idx] <= 0:
		var piece_id = game_state.piece_id[defender_idx]
		kill_piece(game_state, defender_idx)
		if !is_sim:
			visuals.erase_piece(piece_id)
