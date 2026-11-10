extends Node

var game_state:GameState
var move_data:MoveData

var piece_idx:int
var piece_type:int
var num_moves:int
var num_actions:int
var legal_moves:Array
var legal_attacks:Array
var active_indicators:Array = []
var moving:bool = false
var attacking:bool = false
var force_move:bool = false
var use_temp_piece:bool = false

# references
@onready var visuals = $"../Visuals"
@onready var turn_ui = $"../UI Layer/TurnUI"
@onready var board_manager = $"../BoardManager"
@onready var move_button = $"../UI Layer/TurnUI/MoveButton"
@onready var attack_button = $"../UI Layer/TurnUI/AttackButton"

# signals
signal turn_over()

func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	var mouse_idx = Utilities.global_to_index(get_viewport().get_mouse_position())
	var mouse_vec = Utilities.index_to_vector(mouse_idx)
	$"../UI Layer/HUD/MouseLocation".text = "Mouse pos: " + \
		"[" + str(int(mouse_vec.x)) + ", " + str(int(mouse_vec.y)) + "]" + "\nMouse idx: " + \
		str(int(mouse_idx))


func on_player_turn(game_state_in:GameState, move_data_in:MoveData):
	move_button.disabled = false
	attack_button.disabled = false
	game_state = game_state_in
	move_data = move_data_in
	piece_idx = game_state.turn_order[0]
	piece_type = game_state.type[piece_idx]
	num_moves = game_state.num_moves[piece_idx]
	num_actions = game_state.num_actions[piece_idx]
	turn_ui.show()

func _on_move_pressed():
	if !force_move:
		moving = !moving
		attacking = false
	visuals.remove_indicators()

	if (!moving or num_moves <= 0):
		visuals.remove_indicators()
		return
		
	legal_moves = move_data.piece_move_dictionary[piece_type][piece_idx]
	#var type = game_state.type[piece_idx]
	var possible_moves = move_data.piece_move_dictionary[piece_type]
	for move_idx in possible_moves[piece_idx]:
		visuals.create_indicators("Move", move_idx)


func _on_attack_pressed():
	attacking = !attacking
	moving = false
	visuals.remove_indicators()
	if (!attacking or num_actions <= 0):
		visuals.remove_indicators()
		return
	
	legal_attacks = move_data.piece_attacks_dictionary[piece_type][piece_idx]
	for attack_idx in legal_attacks:
		visuals.create_indicators("Attack", attack_idx)


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

	if !moving and !attacking:
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

		if moving and legal_moves.has(clicked_square):
			force_move = board_manager.move_piece_to_idx(game_state, piece_idx, clicked_square, false, use_temp_piece)
			visuals.update_piece(game_state, clicked_square)
			visuals.remove_indicators()

			if !force_move:
				use_temp_piece = false
				piece_idx = game_state.turn_order[0]
				piece_type = game_state.type[piece_idx]
				num_moves = game_state.num_moves[piece_idx]
				num_actions = game_state.num_actions[piece_idx]
				num_moves -= 1
				moving = !moving

				if game_state.passive_abilities[piece_idx] == 2: # "shared" passive ability
					var lower = min(num_moves, num_actions)
					num_moves = lower
					num_actions = lower

			else: # on double jump, save temp location
				piece_idx = clicked_square
				use_temp_piece = true
				_on_move_pressed()
		
		if attacking and legal_attacks.has(clicked_square):
			board_manager.attack_piece(game_state,piece_idx, clicked_square, false, false)
			visuals.remove_indicators()
			
			piece_idx = clicked_square
			num_actions -= 1
			
			if game_state.passive_abilities[piece_idx] == 2: # "shared" passive ability
				var lower = min(num_moves, num_actions)
				num_moves = lower
				num_actions = lower
			
			attacking = !attacking
			
	if num_moves <= 0:
		move_button.disabled = true
	if num_actions <= 0:
		attack_button.disabled = true
