extends Node


var game_state:GameState

@onready var game_over:bool = false
enum results{PLAYER_WIN, OPPONENT_WIN, TIE}
@onready var game_result:results = results.TIE

# References
@onready var board_manager = $"../BoardManager"
@onready var player_controller = $"../PlayerController"
@onready var opponent_controller = $"../OpponentController"
@onready var turn_label:Label = $"../UI Layer/HUD/Label"


func run_game_loop_manager(game_state_in:GameState, move_data:MoveData):
	game_state = game_state_in
	while !game_over:
		var playing_piece_idx:int = game_state.turn_order[0]
		if game_state.values[playing_piece_idx] < 0:
			turn_label.text = "Current Turn:\n Player"
			on_player_turn(game_state, move_data)
			await player_controller.turn_over
		elif game_state.values[playing_piece_idx] > 0:
			turn_label.text = "Current Turn:\n Opponent"
			on_opponent_turn(game_state, move_data)
			await opponent_controller.turn_over
		else:
			push_error("ERROR: Current piece value is zero, is this the wrong index?")
		
		progress_turn_order(game_state.turn_order)
		check_win_conditions(game_state)
		verifications()
		await get_tree().create_timer(1).timeout
	
	return game_result


# Player's turn
func on_player_turn(game_state:GameState, move_data:MoveData):
	player_controller.on_player_turn(game_state, move_data)


func on_opponent_turn(game_state:GameState, move_data:MoveData):
	opponent_controller.on_opponent_turn(game_state, move_data)


# Verify pieces are all placed properly, etc.
func verifications():
	pass
	
# Check if win condition has been met
# TODO: alternate win conditions?
func check_win_conditions(game_state:GameState):
	var num_opponent:int = 0
	var num_player:int = 0
	for idx in game_state.turn_order:
		if game_state.values[idx] > 0:
			num_opponent += 1
		else:
			num_player += 1
		
	if num_player == 0:
		game_result = results.OPPONENT_WIN
		game_over = true
		turn_label.text = "Current Turn:\n OPPONENT WINS"
		return

	if num_opponent == 0:
		game_result = results.PLAYER_WIN
		game_over = true
		turn_label.text = "Current Turn:\n PLAYER WINS"
		return
	return


# Pop the first item and add it to the back of the queue
func progress_turn_order(turn_order:PackedInt32Array):
	var first = turn_order[0]
	turn_order.remove_at(0)
	turn_order.append(first)
