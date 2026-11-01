class_name GameStateOld
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
func make_copy()->GameStateOld:
	# Copy game board objects and turn order
	var new_board:Array
	new_board.resize(board.size())
	var new_turn_order:Array
	new_turn_order.resize(turn_order.size())
	
	for i in board.size():
		var tile = board[i]
		if tile is PieceData:
			var new_tile = PieceData.new(tile.index, tile.value, tile.speed,
										tile.health, tile.attack_damage, tile.player_owned, 
										tile.num_moves, tile.num_attacks, tile.possible_moves)

			new_board[i] = new_tile # Add to new board
			new_turn_order[turn_order.find(tile)] = new_tile

	var new_game_state:GameStateOld = GameStateOld.new(new_board,new_turn_order)
	return new_game_state
