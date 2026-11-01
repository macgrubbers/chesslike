class_name Knight extends Sprite2D

var piece_id:int


func _init(new_id:int) -> void:
	piece_id = new_id
	texture = load("res://icon.svg")
	scale = Vector2(0.4,0.4)

func kill():
	queue_free()
