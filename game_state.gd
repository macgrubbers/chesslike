class_name GameState
extends RefCounted

## Board data
#var tile_ids: PackedInt32Array # DO NOT COPY, for visuals
var turn_order: PackedInt32Array ## The piece's place in the turn order
var move_chain: Array
#var terrain: PackedInt32Array ## Terrain type on the given tile

## Piece data
var piece_id: PackedInt32Array ## Unique ID of each piece
var type: PackedInt32Array ## Type ID of the piece
var values: PackedInt32Array ## score value of the piece for minimax
var health: PackedInt32Array ## health points of the piece
var num_moves: PackedInt32Array	## number of moves a piece can do
var num_actions: PackedInt32Array ## number of actions a piece can do
var passive_abilities: PackedInt32Array ## passive abilities a piece has
var attack_damage: PackedInt32Array ## attack points of the piece
var temp_tile: Array ## Stores a temp piece in between multi moves
## [current_idx, temp_idx, id, type, val, hp, #moves, #actions, passives, attack]

'''
PASSIVE ABILITIES
0 - none
1 - knight's move-attack "double jump"
2 - Shared move-attack pool
'''

func copy()->GameState:
	var new_copy = GameState.new()
	new_copy.turn_order = turn_order.duplicate()
	new_copy.move_chain = move_chain.duplicate()
	new_copy.piece_id = piece_id.duplicate()
	new_copy.type = type.duplicate()
	new_copy.values = values.duplicate()
	new_copy.health = health.duplicate()
	new_copy.num_moves = num_moves.duplicate()
	new_copy.num_actions = num_actions.duplicate()
	new_copy.passive_abilities = passive_abilities.duplicate()
	new_copy.attack_damage = attack_damage.duplicate()
	new_copy.temp_tile = temp_tile.duplicate()
	#copy.armor = armor.duplicate()
	#copy.statuses = statuses.duplicate()
	return new_copy
