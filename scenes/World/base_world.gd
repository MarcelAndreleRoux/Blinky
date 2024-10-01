extends Node2D

class_name BaseWorld

@onready var background = $Background
@onready var semi_cleaning_overlay = $SemiCleaningOverlay

@onready var pause_menu = $PasueMenu
@onready var uic = $UIC

@export var inactive_timer: float = 40.0
@export var speed_multiplier: float = 1.0
@export var time_covered_for_semi: int = 30
@export var time_covered_for_bad: int = 60

enum BackgroundState {
	CLEAN,
	SEMI,
	BAD
}

var mouse_click = preload("res://assets/sprites/UI/Crosshair/Dark/Hands/Hand3.png")
var mouse_release = preload("res://assets/sprites/UI/Crosshair/Light/Hands/Hand3.png")
var timeout_timer: Timer
var paused: bool = false
var time_elapsed: float = 0.0

var current_state: BackgroundState = BackgroundState.CLEAN

var progress_bar: TextureProgressBar

func _ready():
	AudioController.play_audio("Track1", 15.0)
	background.play("clean")
	pause_menu.hide()
	
	progress_bar = uic.texture_progress_bar
	
	progress_bar.max_value = time_covered_for_bad + 8
	progress_bar.value = progress_bar.max_value
	
	timeout_timer = Timer.new()
	add_child(timeout_timer)
	timeout_timer.timeout.connect(_on_timeout)
	
	timeout_timer.start(inactive_timer)

func _process(delta):
	# Update time progression and apply speed multiplier
	time_elapsed += delta * speed_multiplier
	
	update_progress_bar()
	
	if semi_cleaning_overlay.frame == 6:
		get_tree().change_scene_to_file("res://scenes/World/clean_level.tscn")
	
	if time_elapsed > time_covered_for_semi and current_state == BackgroundState.CLEAN:
		update_background_animation(BackgroundState.SEMI)
	elif time_elapsed > time_covered_for_bad and current_state == BackgroundState.SEMI:
		update_background_animation(BackgroundState.BAD)

func update_progress_bar():
	if time_elapsed <= time_covered_for_bad:
		progress_bar.value = progress_bar.max_value - time_elapsed
	else:
		progress_bar.value = 0

func _input(event):
	# Only restart the timer if there's mouse motion or clicks
	if event is InputEventMouseMotion or event.is_action_pressed("click") or event.is_action_released("click"):
		timeout_timer.start(inactive_timer)
	
	if event.is_action_pressed("pause"):
		pauseMenu()
	
	if event.is_action_pressed("click"):
		AudioController.play_audio("click", -10.0)

		# Check if the axolotl is in the resting states before emitting the signal
		if AxolotlState.current_state == AxolotlState.State.RESTING or AxolotlState.current_state == AxolotlState.State.RESTING_B:
			Global.clicked.emit(true)
		
		Input.set_custom_mouse_cursor(mouse_click, Input.CURSOR_ARROW, Vector2(0, 0))
	elif event.is_action_released("click"):
		Global.clicked.emit(false)
		Input.set_custom_mouse_cursor(mouse_release, Input.CURSOR_ARROW, Vector2(0, 0))

func update_background_animation(new_state: BackgroundState):
	current_state = new_state
	
	if current_state == BackgroundState.CLEAN:
		background.play("clean")
		AudioController.stop_audio("Track1")
		AudioController.play_audio("Track2", 15.0)
	elif current_state == BackgroundState.SEMI:
		background.play("semi")
		semi_cleaning_overlay.play("start")
		AudioController.stop_audio("Track1")
		AudioController.play_audio("Track2", 15.0)
	elif current_state == BackgroundState.BAD:
		background.play("bad")
		AudioController.stop_audio("Track2")
		AudioController.play_audio("Track3", 15.0)

func change_background_speed(toggle: bool):
	if toggle:
		speed_multiplier = 2.0
		background.speed_scale = speed_multiplier
	else:
		speed_multiplier = 1.0
		background.speed_scale = speed_multiplier

func pauseMenu():
	if paused:
		pause_menu.hide()
		Engine.time_scale = 1
	else:
		pause_menu.show()
		Engine.time_scale = 0
	
	paused = !paused

func _on_timeout():
	# When the timer expires, set axolotl to resting state
	AxolotlState.on_inactive_timeout()
