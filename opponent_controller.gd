extends Node

var legal_moves:Array
var active_indicators:Array

# References
@onready var game = $".."
@onready var space_indicator:PackedScene = load("res://MoveIndicator.tscn")
@onready var piece_manager = $"../PieceManager"
@onready var turn_manager = $"../TurnManager"
@onready var visuals = $"../Visuals"
@onready var ai = $OpponentAI


signal turn_over

func opponent_turn(piece:PieceData):
	for move in piece.possible_moves[piece.index]:
		# TODO: Move indicators elsewhere
		var move_global = Utilities.grid_to_global(move)
		var new_indicator = space_indicator.instantiate()
		get_tree().current_scene.add_child(new_indicator)
		new_indicator.set_global_position(move_global)
		active_indicators.append(new_indicator)

	await get_tree().create_timer(1).timeout # TODO: remove, just for show rn
	
	var best_move = ai.get_best_move(game.game_state, 4)

	var overlap_piece = piece_manager.move_piece_to_idx(game.game_state.board, piece, best_move)
	if overlap_piece: # Damage the piece, or kill it in this case
		piece_manager.kill_piece(game.game_state, overlap_piece)
	visuals.update_piece(piece)
	end_turn()


func end_turn():
	legal_moves.clear()
	clear_indicators()
	turn_over.emit()


func clear_indicators():
	for indicator in active_indicators:
		indicator.queue_free()
	active_indicators.clear()
