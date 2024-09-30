extends Node2D

var mouse_click = preload("res://assets/sprites/UI/Crosshair/Dark/Hands/Hand3.png")
var mouse_release = preload("res://assets/sprites/UI/Crosshair/Light/Hands/Hand3.png")

func _input(event):
	if event.is_action_pressed("click"):
		AudioController.play_audio("click", -10.0)
		Input.set_custom_mouse_cursor(mouse_click, Input.CURSOR_ARROW, Vector2(0,0))
	elif event.is_action_released("click"):
		Input.set_custom_mouse_cursor(mouse_release, Input.CURSOR_ARROW, Vector2(0,0))
