class_name PieceData 
extends RefCounted

var index:int
var value:int
var speed:int
var player_owned:bool

@export var base_moves:Array = [Vector2(-2, -1), Vector2(-2, 1), Vector2(2, -1), Vector2(2, 1),
								Vector2(-1, -2), Vector2(-1, 2), Vector2(1, -2), Vector2(1, 2),
								Vector2(2,0), Vector2(0,2), Vector2(-2,0), Vector2(0,-2)]

var possible_moves:Array

func _init(new_index:int = 0, new_value:int = 500, 
			new_player_owned:bool = false, new_possible_moves:Array = []) -> void:
	index = new_index
	value = new_value
	player_owned = new_player_owned
	possible_moves = new_possible_moves
