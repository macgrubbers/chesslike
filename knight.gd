class_name Knight extends Sprite2D

var data:PieceData


func _init(new_data:PieceData) -> void:
	data = new_data
	texture = load("res://icon.svg")
	scale = Vector2(0.4,0.4)

func kill():
	queue_free()
