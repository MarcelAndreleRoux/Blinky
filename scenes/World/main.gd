extends Node2D

class_name BaseWorld

@onready var background = $Background
@onready var semi_cleaning_overlay = $SemiCleaningOverlay
@onready var bad_cleaning_overlay = $BadCleaningOverlay
@onready var axolotl = $Axolotl
@onready var mouse_clean_skin = $MouseSkin
@onready var uic = $UIC

@onready var pause_menu = $PasueMenu

@export var inactive_timer: float = 10.0
@export var speed_multiplier: float = 1.0
@export var time_covered_for_semi: int = 30
@export var time_covered_for_bad: int = 50

enum BackgroundState {
	CLEAN,
	SEMI,
	BAD
}

var current_state: BackgroundState = BackgroundState.CLEAN
var time_elapsed: float = 0.0
var paused: bool = false
var not_start_semi: bool = false
var not_start_bad: bool = false

var button_press: bool = false
var screen_press: bool = false
var cleaning: bool = false
var should_clean: bool = false

var mouse_skin = preload("res://assets/sprites/UI/Crosshair/mouse_skin.png")
var mouse_click = preload("res://assets/sprites/UI/Crosshair/Dark/Hands/Hand3.png")
var mouse_release = preload("res://assets/sprites/UI/Crosshair/Light/Hands/Hand3.png")

var progress_bar: TextureProgressBar
var timeout_timer: Timer
var mouse_change_timer: Timer

func _ready():
	AudioController.play_audio("Track1", 15.0)
	initialize_timers()

	# Initial background state
	match current_state:
		BackgroundState.CLEAN:
			should_clean = false
			background.play("clean")
			semi_cleaning_overlay.visible = false
			bad_cleaning_overlay.visible = false
		BackgroundState.SEMI:
			should_clean = true
			background.play("semi")
			semi_cleaning_overlay.visible = true
			semi_cleaning_overlay.play("start")
			bad_cleaning_overlay.visible = false
		BackgroundState.BAD:
			should_clean = true
			background.play("bad")
			semi_cleaning_overlay.visible = true  # Keep semi overlay visible
			bad_cleaning_overlay.visible = true
			bad_cleaning_overlay.play("start")

	# Initialize cleaning-related timers
	mouse_clean_skin.visible = false
	mouse_change_timer = Timer.new()
	add_child(mouse_change_timer)
	mouse_change_timer.timeout.connect(_on_change_timer_timeout)

func initialize_timers():
	timeout_timer = Timer.new()
	add_child(timeout_timer)
	timeout_timer.timeout.connect(_on_timeout)
	timeout_timer.start(inactive_timer)

	progress_bar = uic.texture_progress_bar
	progress_bar.max_value = time_covered_for_bad
	progress_bar.value = progress_bar.max_value

func _process(delta):
	# Update time progression and apply speed multiplier
	if cleaning:
		# Do not change time_elapsed when cleaning
		pass
	else:
		time_elapsed += delta * speed_multiplier
		if time_elapsed > time_covered_for_bad:
			time_elapsed = time_covered_for_bad
	update_progress_bar()
	check_background_state_transitions()

	# Check if cleaning overlays have reached frame 6
	if current_state == BackgroundState.BAD and not_start_bad and bad_cleaning_overlay.get_frame() == 6:
		not_start_bad = false
		bad_cleaning_overlay.stop()
		bad_cleaning_overlay.frame = 0  # Reset overlay animation
		bad_cleaning_overlay.visible = false  # Hide bad overlay after cleaning
		# Set time_elapsed to a safe value below time_covered_for_bad
		time_elapsed = time_covered_for_semi
		update_progress_bar()
		update_background_animation(BackgroundState.SEMI)
	elif current_state == BackgroundState.SEMI and not_start_semi and semi_cleaning_overlay.get_frame() == 6:
		not_start_semi = false
		semi_cleaning_overlay.stop()
		semi_cleaning_overlay.frame = 0  # Reset overlay animation
		semi_cleaning_overlay.visible = false  # Hide semi overlay after cleaning
		time_elapsed = 0.0  # Reset time_elapsed to fully clean
		update_progress_bar()
		update_background_animation(BackgroundState.CLEAN)

	# Update mouse skin position to follow the cursor
	mouse_clean_skin.position = to_local(get_global_mouse_position())

func check_background_state_transitions():
	if current_state == BackgroundState.BAD:
		# Do not transition out of BAD state based on time_elapsed
		pass
	elif time_elapsed >= time_covered_for_bad and current_state != BackgroundState.BAD:
		update_background_animation(BackgroundState.BAD)
	elif time_elapsed >= time_covered_for_semi and current_state != BackgroundState.SEMI:
		update_background_animation(BackgroundState.SEMI)
	elif time_elapsed < time_covered_for_semi and current_state != BackgroundState.CLEAN:
		update_background_animation(BackgroundState.CLEAN)

func update_progress_bar():
	# Adjust the progress bar based on elapsed time
	progress_bar.value = progress_bar.max_value - time_elapsed

func _input(event):
	# Restart timer on motion or click
	if event is InputEventMouseMotion or event.is_action_pressed("click") or event.is_action_released("click"):
		timeout_timer.start(inactive_timer)

	# Pause game if needed
	if event.is_action_pressed("pause"):
		pauseMenu()

	# Handle mouse click for cleaning actions
	if event.is_action_pressed("click"):
		AudioController.play_audio("click", 1.0)

		if should_clean:
			cleaning = true
			mouse_clean_skin.visible = true
			mouse_clean_skin.play("sponge_clean")
			
			if current_state == BackgroundState.SEMI:
				not_start_semi = true
				semi_cleaning_overlay.play("cleaning")
			elif current_state == BackgroundState.BAD:
				not_start_bad = true
				bad_cleaning_overlay.play("cleaning")

			Input.set_custom_mouse_cursor(mouse_skin, Input.CURSOR_ARROW, Vector2(0, 0))
		else:
			Input.set_custom_mouse_cursor(mouse_release, Input.CURSOR_ARROW, Vector2(0, 0))

		# Update Axolotl state if needed
		if AxolotlState.current_state in [AxolotlState.State.RESTING, AxolotlState.State.RESTING_B]:
			Global.clicked.emit(true)
	elif event.is_action_released("click"):
		if should_clean:
			cleaning = false
			mouse_clean_skin.play("sponge")

			if current_state == BackgroundState.SEMI:
				semi_cleaning_overlay.stop()
			elif current_state == BackgroundState.BAD:
				bad_cleaning_overlay.stop()

			mouse_change_timer.start(5)

		Global.clicked.emit(false)

func _on_change_timer_timeout():
	Input.set_custom_mouse_cursor(mouse_release, Input.CURSOR_ARROW, Vector2(0, 0))
	mouse_clean_skin.visible = false

func update_background_animation(new_state: BackgroundState):
	if current_state == new_state:
		return  # Prevent re-initialization if the state hasn't changed

	current_state = new_state

	# Stop all audio tracks before starting a new one
	AudioController.stop_audio("Track1")
	AudioController.stop_audio("Track2")
	AudioController.stop_audio("Track3")

	match current_state:
		BackgroundState.CLEAN:
			print("entered clean")
			cleaning = false
			should_clean = false
			background.play("clean")
			semi_cleaning_overlay.visible = false
			bad_cleaning_overlay.visible = false
			AudioController.play_audio("Track1", 15.0)
		BackgroundState.SEMI:
			print("entered semi")
			should_clean = true
			background.play("semi")
			semi_cleaning_overlay.visible = true
			# Do not replay the semi overlay's "start" animation
			bad_cleaning_overlay.visible = false
			AudioController.play_audio("Track2", 15.0)
		BackgroundState.BAD:
			print("entered bad")
			should_clean = true
			background.play("bad")
			semi_cleaning_overlay.visible = true  # Keep semi overlay visible
			bad_cleaning_overlay.visible = true
			bad_cleaning_overlay.play("start")
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
	AxolotlState.on_inactive_timeout()
