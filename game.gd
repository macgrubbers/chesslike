extends Node2D

@onready var game_state:GameState
@onready var tile_size:int = 16
@onready var knight = preload("res://Knight.tscn")
@onready var piece_data = preload("res://piece_data.gd")

# References
#@onready var player = $Knight
#@onready var opponent = $Opponent
@onready var visuals = $Visuals
@onready var turn_manager = $TurnManager
@onready var piece_manager = $PieceManager
@onready var player_controller = $PlayerController



func _ready() -> void:
	Utilities.set_utilities_constants(tile_size, visuals.origin, visuals.scale[0])
	
	setup_game_state()
	
	# Adds pieces to the board
	piece_manager.setup(game_state)

	# Update turn order
	turn_manager.setup(game_state)

	# Setup the visuals
	visuals.setup(game_state)


	# Connect signal
	## TODO: move this
	$"UI Layer/TurnUI/MoveButton".connect("pressed", player_controller._on_move_pressed)

	
	await get_tree().create_timer(1).timeout
	await turn_manager.run_turn_manager()
	await get_tree().create_timer(1.5).timeout
	get_tree().quit()

func setup_game_state():
	var board_array:Array
	board_array.resize(64)
	var turn_order:Array
	game_state = GameState.new(board_array,turn_order)
	
	$PlayerController.game_state = game_state
