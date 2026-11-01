extends Node

var game_state:GameState
var move_data:MoveData

var piece_idx:int
var piece_type_id:int
var num_moves:int
var legal_moves:Array
var active_indicators:Array = []
var moving:bool = false
var force_move:bool = false

# references
@onready var visuals = $"../Visuals"
@onready var turn_ui = $"../UI Layer/TurnUI"
@onready var space_indicator:PackedScene = load("res://MoveIndicator.tscn")
@onready var board_manager = $"../BoardManager"

# signals
signal turn_over()

func _ready() -> void:
	pass

func on_player_turn(game_state_in:GameState, move_data_in:MoveData):
	game_state = game_state_in
	move_data = move_data_in
	piece_idx = game_state.turn_order[0]
	piece_type_id = game_state.type_id[piece_idx]
	num_moves = game_state.num_moves[piece_idx]
	turn_ui.show()

func _on_move_pressed():
	moving = !moving
	if (!moving or num_moves <= 0):
		visuals.remove_indicators()
		return
		
	legal_moves = move_data.piece_move_dictionary[piece_type_id][piece_idx]
	var type_id = game_state.type_id[piece_idx]
	var possible_moves = move_data.piece_move_dictionary[type_id]
	for move_idx in possible_moves[piece_idx]:
		visuals.create_indicators(move_idx)


func _on_end_turn_pressed():
	end_turn()


func end_turn():
	moving = false
	turn_ui.hide()
	visuals.remove_indicators()
	turn_over.emit()


func _unhandled_input(event: InputEvent) -> void:
	#if Input.is_key_pressed(KEY_ESCAPE):
		#print("pause!")
		#get_tree().paused = !get_tree().paused

	if !moving and !force_move:
		return
	#
	########################
	## Mouse Input Movement
	########################
	# Check for left-click press
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var local_mouse_pos = get_viewport().get_mouse_position()
			
			# Calculate the grid coordinate (0 to 7)
		var clicked_square:int = Utilities.global_to_index(local_mouse_pos)

		if legal_moves.has(clicked_square):
			
			board_manager.move_piece_to_idx(game_state, piece_idx, clicked_square)
			
			visuals.update_piece(game_state.piece_id[clicked_square], clicked_square)
			visuals.remove_indicators()
			
			piece_idx = clicked_square
			num_moves -= 1
			
			moving = !moving
			
