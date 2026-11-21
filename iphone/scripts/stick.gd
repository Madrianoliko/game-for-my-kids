extends Control

var vector := Vector2.ZERO
var finger := -1

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	queue_redraw()

func _draw() -> void:
	var center := size * 0.5
	draw_circle(center, 63, Color("#17283be0"), true, -1, true)
	draw_arc(center, 60, 0, TAU, 60, Color("#e4d0a0"), 3, true)
	draw_circle(center + vector * 33, 26, Color("#efc66b"), true, -1, true)
	draw_circle(center + vector * 33 - Vector2(5,6), 13, Color("#ffde92"), true, -1, true)

func reset() -> void:
	finger = -1
	vector = Vector2.ZERO
	queue_redraw()

func _input(e: InputEvent) -> void:
	if not is_visible_in_tree(): return
	if e is InputEventScreenTouch:
		if e.pressed and finger == -1 and get_global_rect().has_point(e.position): finger = e.index
		if e.index != finger: return
		if not e.pressed or e.canceled: reset()
		else: move_thumb(e.position)
	elif e is InputEventScreenDrag and e.index == finger:
		move_thumb(e.position)

func move_thumb(point: Vector2) -> void:
	vector = ((point - global_position - size * 0.5) / 46.0).limit_length(1.0)
	if vector.length() < 0.12: vector = Vector2.ZERO
	queue_redraw()
