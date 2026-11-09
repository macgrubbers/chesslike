class_name HealthBar extends PanelContainer

@export var max_health: int = 5
@export var margin_horizontal := 2
@export var margin_vertical := 2
@export var full_color := Color("e63946")
@export var empty_color := Color("3a3a3a")
#@export var segment_size := Vector2(24, 20)
var _segments: Array[ColorRect] = []
var _health: int

@onready var container: HBoxContainer = $MarginContainer/HBoxContainer
@onready var margin: MarginContainer = $MarginContainer



## Offset from the parent's origin after centering. Negative Y puts the bar above it.
@export var offset := Vector2(0, 20)


func setup(new_max_health:int) -> void:
	resized.connect(_recenter)
	margin.add_theme_constant_override("margin_left", margin_horizontal)
	margin.add_theme_constant_override("margin_right", margin_horizontal)
	margin.add_theme_constant_override("margin_top", margin_vertical)
	margin.add_theme_constant_override("margin_bottom", margin_vertical)

	max_health = new_max_health
	_build_segments()
	set_health(new_max_health)
	custom_minimum_size = Vector2(60, 15)


func _recenter() -> void:
	position = -size / 2.0 + offset
	

func _build_segments() -> void:
	for child in container.get_children():
		child.queue_free()
	_segments.clear()

	for i in max_health:
		var seg := ColorRect.new()
		#seg.custom_minimum_size = segment_size
		seg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		container.add_child(seg)
		_segments.append(seg)
	reset_size.call_deferred()

func set_health(value: int) -> void:
	_health = clampi(value, 0, max_health)
	for i in _segments.size():
		_segments[i].color = full_color if i < _health else empty_color
