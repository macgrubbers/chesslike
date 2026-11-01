extends Node

var piece_idx
var active_indicators:Array

# References
@onready var game = $".."
@onready var space_indicator:PackedScene = load("res://MoveIndicator.tscn")
@onready var board_manager = $"../BoardManager"
@onready var game_loop_manager = $"../GameLoopManager"
@onready var visuals = $"../Visuals"
@onready var ai = $OpponentAI


signal turn_over

func on_opponent_turn(game_state:GameState, move_data:MoveData):
	piece_idx = game_state.turn_order[0]
	var type_id = game_state.type_id[piece_idx]
	var possible_moves = move_data.piece_move_dictionary[type_id]

	for move_idx in possible_moves[piece_idx]:
		visuals.create_indicators(move_idx)

	await get_tree().create_timer(1).timeout # TODO: remove, just for show rn
	
	#var best_move = ai.get_best_move(game.game_state, 4)

	var best_move = possible_moves[piece_idx].pick_random()

	board_manager.move_piece_to_idx(game.game_state, piece_idx, best_move)
	visuals.update_piece(game_state.piece_id[best_move], best_move)

	end_turn()


func end_turn():
	visuals.remove_indicators()
	turn_over.emit()


func clear_indicators():
	for indicator in active_indicators:
		indicator.queue_free()
	active_indicators.clear()
