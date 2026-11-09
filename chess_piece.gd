class_name ChessPiece extends Sprite2D

var piece_id:int
var type:int
var player_owned:bool
var health:int

var piece_dictionary:Dictionary = {
	1 : [load("res://art/black_knight.png"), load("res://art/white_knight.png")],
	2 : [load("res://art/black_pawn.png"), load("res://art/white_pawn.png")]
}

@onready var health_bar:HealthBar = $HealthBar

func _ready() -> void:
	health_bar.setup(health)


func setup(game_state:GameState, idx:int) -> void:
	player_owned = (false if game_state.values[idx] > 0 else true)
	piece_id = game_state.piece_id[idx]
	type = game_state.type[idx]
	health = game_state.health[idx]
	texture = piece_dictionary[type][int(player_owned)]


func update_health(new_health:int):
	health_bar.set_health(new_health)

func kill():
	queue_free()
