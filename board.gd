extends TileMapLayer

var bitboard:Array

@onready var width:int = 8
@onready var height:int = 8
@onready var origin:Vector2 = $Origin.global_position
@onready var active_indicators:Array =[]

@onready var knight = preload("res://Knight.tscn")
@onready var move_indicator:PackedScene = load("res://MoveIndicator.tscn")
@onready var attack_indicator:PackedScene = load("res://AttackIndicator.tscn")

func _ready() -> void:
	bitboard.resize(width * height)


func setup(game_state:GameState):
	for idx in game_state.type.size():
		if game_state.type[idx] == 1:
			var new_piece = Knight.new(game_state.piece_id[idx])
			get_tree().current_scene.add_child(new_piece)
			new_piece.set_global_position(Utilities.index_to_global(idx))
			new_piece.add_to_group("Pieces")
			new_piece.z_index = 5

# Given a piece data reference, find its corresponding visual object
#	and update it
func update_piece(piece_id:int, new_idx:int):
	for piece:Knight in get_tree().get_nodes_in_group("Pieces"):
		if piece.piece_id == piece_id and piece_id != 0:
			var new_pos = Utilities.index_to_global(new_idx)
			piece.set_global_position(new_pos)


func erase_piece(piece_id:int):
	for piece:Knight in get_tree().get_nodes_in_group("Pieces"):
		if piece.piece_id == piece_id:
			piece.queue_free()


func create_indicators(type:String, at_idx:int):
	var indicator_global_pos = Utilities.index_to_global(at_idx)
	var new_indicator
	if type == "Move":
		new_indicator = move_indicator.instantiate()
	else:
		new_indicator = attack_indicator.instantiate()
	get_tree().current_scene.add_child(new_indicator)
	new_indicator.set_global_position(indicator_global_pos)
	active_indicators.append(new_indicator)


func remove_indicators():
	for indicator in active_indicators:
		indicator.queue_free()
	active_indicators = []
