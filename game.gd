extends Node2D

var game_state:GameState
var move_data:MoveData

@onready var tile_size:int = 16
@onready var knight = preload("res://Knight.tscn")
@onready var piece_data = preload("res://piece_data.gd")

# References
#@onready var player = $Knight
#@onready var opponent = $Opponent
@onready var visuals = $Visuals
@onready var game_loop_manager = $GameLoopManager
@onready var board_manager = $BoardManager
@onready var player_controller = $PlayerController



func _ready() -> void:
	Utilities.set_utilities_constants(tile_size, visuals.origin, visuals.scale[0])
	
	setup()
	
	# Adds pieces, setup turn order
	board_manager.setup(game_state, move_data)

	# Setup the visuals
	visuals.setup(game_state)


	# Connect signal
	## TODO: move this
	$"UI Layer/TurnUI/MoveButton".connect("pressed", player_controller._on_move_pressed)
	$"UI Layer/TurnUI/AttackButton".connect("pressed", player_controller._on_attack_pressed)
	$"UI Layer/TurnUI/EndTurnButton".connect("pressed", player_controller._on_end_turn_pressed)
	
	await get_tree().create_timer(1).timeout
	await game_loop_manager.run_game_loop_manager(game_state, move_data)
	await get_tree().create_timer(1.5).timeout
	get_tree().quit()


# TODO: Read from a JSON file instead
func setup():
	move_data = MoveData.new()
	game_state = GameState.new()
	var array_size = 64
	#game_state.tile_ids.resize(array_size)
	game_state.turn_order.resize(array_size)
	game_state.piece_id.resize(array_size)
	game_state.type.resize(array_size)
	game_state.values.resize(array_size)
	game_state.health.resize(array_size)
	game_state.num_moves.resize(array_size)
	game_state.num_actions.resize(array_size)
	game_state.passive_abilities.resize(array_size)
