class_name GameState
extends RefCounted

## Board data
#var tile_ids: PackedInt32Array # DO NOT COPY, for visuals
var turn_order: PackedInt32Array ## The piece's place in the turn order
#var terrain: PackedInt32Array ## Terrain type on the given tile

## Piece data
var piece_id: PackedInt32Array ## Unique ID of each piece
var type_id: PackedInt32Array ## Type ID of the piece
var values: PackedInt32Array ## score value of the piece for minimax
var health: PackedInt32Array ## health points of the piece
var num_moves: PackedInt32Array	## number of moves a piece can do
var num_actions: PackedInt32Array ## number of actions a piece can do
var passive_abilities: PackedInt32Array ## passive abilities a piece has
#var attack: PackedInt32Array ## attack points of the piece
#var armor: PackedInt32Array ## armor points of the piece
#var statuses: PackedInt32Array

'''
PASSIVE ABILITIES bit flags
0 - none
1 - knight's double jump ability
'''

func clone()->GameState:
	var copy = GameState.new()
	copy.turn_order = turn_order.duplicate()
	copy.piece_id = piece_id.duplicate()
	copy.type_id = type_id.duplicate()
	copy.values = values.duplicate()
	copy.health = health.duplicate()
	copy.num_moves = num_moves.duplicate()
	copy.num_actions = num_actions.duplicate()
	#copy.attack = attack.duplicate()
	#copy.armor = armor.duplicate()
	#copy.statuses = statuses.duplicate()
	return copy
