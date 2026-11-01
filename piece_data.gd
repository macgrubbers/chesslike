class_name PieceData 
extends RefCounted

var index:int
var value:int
var health:int
var speed:int
var attack_damage:int
var player_owned:bool
var num_moves:int = 1
var num_attacks:int = 1

@export var base_moves:Array = [Vector2(-2, -1), Vector2(-2, 1), Vector2(2, -1), Vector2(2, 1),
								Vector2(-1, -2), Vector2(-1, 2), Vector2(1, -2), Vector2(1, 2),
								Vector2(2,0), Vector2(0,2), Vector2(-2,0), Vector2(0,-2)]

var possible_moves:Array # TODO: Move these locally

var abilities:Array = ["double_jump"]


func _init(new_index:int = 0, new_value:int = 500, new_speed:int = 1,
			new_health:int = 10,
			new_attack_damage:int = 5, new_player_owned:bool = false, 
			new_num_moves:int = 1, new_num_attacks:int = 1,
			new_possible_moves:Array = []) -> void:
	index = new_index
	value = new_value
	speed = new_speed
	health = new_health
	attack_damage = new_attack_damage
	player_owned = new_player_owned
	num_moves = new_num_moves
	num_attacks = new_num_attacks
	possible_moves = new_possible_moves
