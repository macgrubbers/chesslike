extends TileMapLayer

var bitboard:Array

@onready var width:int = 8
@onready var height:int = 8
@onready var origin:Vector2 = $Origin.global_position

@onready var knight = preload("res://Knight.tscn")

func _ready() -> void:
	bitboard.resize(width * height)


func setup(game_state:GameState):
	var board = game_state.board
	for piece_data in game_state.board:
		if piece_data is PieceData:
			var new_piece = Knight.new(piece_data)
			get_tree().current_scene.add_child(new_piece)
			new_piece.set_global_position(Utilities.grid_to_global(piece_data.index))
			new_piece.add_to_group("Pieces")
			new_piece.z_index = 5

# Given a piece data reference, find its corresponding visual object
#	and update it
func update_piece(data:PieceData):
	for piece:Knight in get_tree().get_nodes_in_group("Pieces"):
		if piece.data == data:
			var new_pos = Utilities.grid_to_global(data.index)
			piece.set_global_position(new_pos)

func erase_piece(data:PieceData):
	for piece:Knight in get_tree().get_nodes_in_group("Pieces"):
		if piece.data == data:
			piece.queue_free()
