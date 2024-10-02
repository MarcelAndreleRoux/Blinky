extends Control

@onready var main = $"../"

func _on_resume_pressed():
	main.pauseMenu()

func _on_quit_pressed():
	get_tree().quit()

func _on_restart_pressed():
	get_tree().reload_current_scene()
	main.pauseMenu()
