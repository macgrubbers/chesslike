extends Node


var game_state:GameState

@onready var game_over:bool = false
enum results{PLAYER_WIN, OPPONENT_WIN, TIE}
@onready var game_result:results = results.TIE

# References
@onready var piece_manager = $"../PieceManager"
@onready var player_controller = $"../PlayerController"
@onready var opponent_controller = $"../OpponentController"
@onready var turn_label:Label = $"../UI Layer/HUD/Label"


func setup(state:GameState):
	game_state = state
	# TODO: Assemble turn order based off piece speed
	for piece in game_state.board:
		if piece is PieceData:
			game_state.turn_order.append(piece)


func run_turn_manager():
	while !game_over:
		var playing_piece:PieceData = game_state.turn_order[0]
		if playing_piece.player_owned:
			turn_label.text = "Current Turn: Player"
			on_player_turn(playing_piece)
			await player_controller.turn_over
		else:
			turn_label.text = "Current Turn: Opponent"
			on_opponent_turn(playing_piece)
			await opponent_controller.turn_over
		
		progress_turn_order(game_state.turn_order)
		#check_win_conditions()
		verifications()
		await get_tree().create_timer(1).timeout
	
	return game_result


# Player's turn
func on_player_turn(piece:PieceData):
	player_controller.player_turn(piece)


func on_opponent_turn(piece:PieceData):
	opponent_controller.opponent_turn(piece)


# Verify pieces are all placed properly, etc.
func verifications():
	pass
	
# Check if win condition has been met
# TODO: alternate win conditions?
func check_win_conditions():
	if piece_manager.get_player_pieces_value() == 0:
		game_result = results.OPPONENT_WIN
		game_over = true
		turn_label.text = "Current Turn: OPPONENT WINS"
		return

	if piece_manager.get_opponent_pieces_value() == 0:
		game_result = results.PLAYER_WIN
		game_over = true
		turn_label.text = "Current Turn: PLAYER WINS"
		return

	return


func progress_turn_order(order:Array):
	var first = order.pop_front()
	order.append(first)
