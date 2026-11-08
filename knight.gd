class_name Knight extends Sprite2D

var piece_id:int


func _init(new_id:int, player_owned:bool = false) -> void:
	piece_id = new_id
	scale = Vector2(4,4)
	
	if player_owned:
		texture = load("res://art/white_knight.png")
	else:
		texture = load("res://art/black_knight.png")

func kill():
	queue_free()
