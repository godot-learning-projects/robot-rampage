@tool
extends Control

func _draw() -> void:
	draw_circle(Vector2.ZERO, 3, Color.DIM_GRAY)
	draw_circle(Vector2.ZERO, 2, Color.WHITE_SMOKE)

	draw_line(Vector2(8, 0), Vector2(16, 0), Color.WHITE_SMOKE)
	draw_line(Vector2(-16, 0), Vector2(-8, 0), Color.WHITE_SMOKE)
	draw_line(Vector2(0, 16), Vector2(0, 8), Color.WHITE_SMOKE)
	draw_line(Vector2(0, -8), Vector2(0, -16), Color.WHITE_SMOKE)
