class_name MoveData
extends Node

var piece_move_dictionary:Dictionary[int, Array] = {}
var piece_attacks_dictionary:Dictionary[int, Array] = {}

var tile_values_dictionary:Dictionary[int,PackedInt32Array] = {
	1: [10, 10, 10, 10, 10, 10, 10, 10,
		10, 15, 15, 15, 15, 15, 15, 10,
		10, 15, 25, 25, 25, 25, 15, 10,
		10, 15, 25, 35, 35, 25, 15, 10,
		10, 15, 25, 35, 35, 25, 15, 10,
		10, 15, 25, 25, 25, 25, 15, 10,
		10, 15, 15, 15, 15, 15, 15, 10,
		10, 10, 10, 10, 10, 10, 10, 10,]
		,
	2: [10, 10, 10, 10, 10, 10, 10, 10,
		10, 15, 15, 15, 15, 15, 15, 10,
		10, 15, 25, 25, 25, 25, 15, 10,
		10, 15, 25, 35, 35, 25, 15, 10,
		10, 15, 25, 35, 35, 25, 15, 10,
		10, 15, 25, 25, 25, 25, 15, 10,
		10, 15, 15, 15, 15, 15, 15, 10,
		10, 10, 10, 10, 10, 10, 10, 10,]
}

# Values based on distance
## TODO: use a curve or function instead?
var distance_scoring_dictionary:Dictionary = {
	1: [0, 5, 5, 4, 2, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0],
	2: [0 ,5, 3, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	3: [0 ,5, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
}


# TODO: maybe have an input file
var base_moves:Dictionary = {
	1 : [Vector2(-2, -1), Vector2(-2, 1), Vector2(2, -1), Vector2(2, 1),
		 Vector2(-1, -2), Vector2(-1, 2), Vector2(1, -2), Vector2(1, 2)],
	2 : [Vector2(1,0), Vector2(-1,0), Vector2(0,1), Vector2(0,-1)],
	3 : [Vector2(1,0), Vector2(-1,0), Vector2(0,1), Vector2(0,-1),
		 Vector2(1,1), Vector2(-1,-1), Vector2(-1,1), Vector2(1,-1)]
}

'''
Base Attacks
1 : "Plus" four tiles
2 : "X" four tiles
'''
var base_attacks:Dictionary = {
	1: [Vector2(1,0), Vector2(-1,0), Vector2(0,1), Vector2(0,-1)],
	2 : [Vector2(1,1), Vector2(-1,-1), Vector2(-1,1), Vector2(1,-1)],
	3 : [Vector2(1,0), Vector2(-1,0), Vector2(0,1), Vector2(0,-1),
		 Vector2(1,1), Vector2(-1,-1), Vector2(-1,1), Vector2(1,-1)]
}


# Creates possible moves for a piece on all given squares
func generate_moves(board_size:int, type:int):
	if piece_move_dictionary.has(type):
		return # We already have this in the dictionary
	var possible_moves:Array
	possible_moves.resize(board_size)
	for i in range(board_size):
		var tile_possible_moves:Array
		var vec = Utilities.index_to_vector(i)
		for move in base_moves[type]:
			var move_vec = vec + move # TODO: maybe theres a way to calculate using bit math
			if Utilities.is_in_bounds(move_vec):
				var idx_move:int = Utilities.vector_to_index(move_vec)
				tile_possible_moves.append(idx_move)
		possible_moves[i] = tile_possible_moves
	piece_move_dictionary[type] = possible_moves
	return


func generate_attacks(board_size:int, type:int):
	if piece_attacks_dictionary.has(type):
		return # We already have this in the dictionary
	var possible_attacks:Array
	possible_attacks.resize(board_size)
	for i in range(board_size):
		var tile_possible_attacks:Array
		var vec = Utilities.index_to_vector(i)
		for move in base_attacks[type]:
			var move_vec = vec + move # TODO: maybe theres a way to calculate using bit math
			if Utilities.is_in_bounds(move_vec):
				var idx_move:int = Utilities.vector_to_index(move_vec)
				tile_possible_attacks.append(idx_move)
		possible_attacks[i] = tile_possible_attacks
	piece_attacks_dictionary[type] = possible_attacks
	return
