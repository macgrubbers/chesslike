class_name MoveData
extends Node

var piece_move_dictionary:Dictionary[int, Array] = {}

# TODO: maybe have an input file
var base_moves:Dictionary = {
	1 : [Vector2(-2, -1), Vector2(-2, 1), Vector2(2, -1), Vector2(2, 1),
		 Vector2(-1, -2), Vector2(-1, 2), Vector2(1, -2), Vector2(1, 2),
		 Vector2(2,0), Vector2(0,2), Vector2(-2,0), Vector2(0,-2)]
}


# Creates possible moves for a piece on all given squares
func generate_moves(board_size:int, type_id:int):
	if piece_move_dictionary.has(type_id):
		return # We already have this in the dictionary
	var possible_moves:Array
	possible_moves.resize(board_size)
	for i in range(board_size):
		var tile_possible_moves:Array
		var vec = Utilities.index_to_vector(i)
		for move in base_moves[type_id]:
			var move_vec = vec + move # TODO: maybe theres a way to calculate using bit math
			if Utilities.is_in_bounds(move_vec):
				var idx_move:int = Utilities.vector_to_index(move_vec)
				tile_possible_moves.append(idx_move)
		possible_moves[i] = tile_possible_moves
	piece_move_dictionary[type_id] = possible_moves
	return
