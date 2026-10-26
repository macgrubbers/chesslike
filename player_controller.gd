extends Node

var game_state:GameState

var active_piece:PieceData
var active_piece_starting_pos:Vector2
var active_indicators:Array = []
var moving:bool = false

# references
@onready var visuals = $"../Visuals"
@onready var turn_ui = $"../UI Layer/TurnUI"
@onready var space_indicator:PackedScene = load("res://MoveIndicator.tscn")
@onready var piece_manager = $"../PieceManager"

# signals
signal turn_over()

func _ready() -> void:
	pass

func player_turn(piece:PieceData):
	active_piece = piece
	active_piece_starting_pos = Utilities.grid_to_global(active_piece.index)
	turn_ui.show()

func _on_move_pressed():
	moving = !moving
	if !moving:
		#active_piece.set_global_position(active_piece_starting_pos)
		$"../UI Layer/TurnUI/ConfirmMoveButton".hide()
		clear_indicators()
		return
	$"../UI Layer/TurnUI/ConfirmMoveButton".show()
	
	for move in active_piece.possible_moves[active_piece.index]:
		var move_global = Utilities.grid_to_global(move)
		var new_indicator = space_indicator.instantiate()
		get_tree().current_scene.add_child(new_indicator)
		new_indicator.set_global_position(move_global)
		active_indicators.append(new_indicator)


func end_turn():
	moving = false
	turn_ui.hide()
	$"../UI Layer/TurnUI/ConfirmMoveButton".hide()
	clear_indicators()
	turn_over.emit()


func clear_indicators():
	for indicator in active_indicators:
		indicator.queue_free()
	active_indicators.clear()


func _unhandled_input(event: InputEvent) -> void:
	#if Input.is_key_pressed(KEY_ESCAPE):
		#print("pause!")
		#get_tree().paused = !get_tree().paused

	if !moving:
		return
	#############
	## WASD Movement
	#############
	#var piece_vec:Vector2 = Utilities.global_to_vector(active_piece.get_global_position())
	#var new_location = piece_vec
	
	#if Input.is_key_pressed(KEY_W):
		#new_location += Vector2(0,-1)
	#if Input.is_key_pressed(KEY_S):
		#new_location += Vector2(0,1)
	#if Input.is_key_pressed(KEY_A):
		#new_location += Vector2(-1,0)
	#if Input.is_key_pressed(KEY_D):
		#new_location += Vector2(1,0)
	
	#if new_location != piece_vec:
		#var can_move = Utilities.is_in_bounds(new_location)
		#if can_move:
			#active_piece.set_global_position(Utilities.vector_to_global(new_location))
	#
	###########
	## Mouse Input Movement
	##########
	# Check for left-click press
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var local_mouse_pos = get_viewport().get_mouse_position()
			
			# Calculate the grid coordinate (0 to 7)
		var clicked_square:int = Utilities.global_to_grid(local_mouse_pos)
		var legal_moves = active_piece.possible_moves[active_piece.index].map(func(element): return int(element))
		if legal_moves.has(clicked_square):
			var overlap = piece_manager.move_piece_to_idx(game_state.board, active_piece, clicked_square)
			if overlap:
				piece_manager.kill_piece(game_state, overlap)
			visuals.update_piece(active_piece)
			end_turn()
