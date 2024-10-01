# User Interface Controller
extends Control

@onready var main = $"../" # just gets main
@onready var player = $"../Axolotl" # just gets player

@onready var clean = $MarginContainer/VBoxContainer/HBoxContainer2/Clean # play the clean game when pressed
@onready var eat = $MarginContainer/VBoxContainer/HBoxContainer2/Eat # play the eat game when pressed
@onready var play = $MarginContainer/VBoxContainer/HBoxContainer2/Play # play the playing game when pressed
@onready var texture_progress_bar = $MarginContainer/VBoxContainer/HBoxContainer3/TextureProgressBar

# pauses the screen when clicked
func _on_pause_button_pressed():
	main.pauseMenu()

# should make time go buy x2 faster (this button should toggle)
func _on_speed_button_toggled(toggled_on):
	if toggled_on:
		player.change_speed(toggled_on)
		main.change_background_speed(toggled_on)
	else:
		player.change_speed(toggled_on)
		main.change_background_speed(toggled_on)
