extends BaseWorld

@onready var bad_cleaning_overlay = $BadCleaningOverlay
@onready var mouse_clean_skin = $MouseSkin

var button_press: bool = false
var screen_press: bool = false
var cleaing: bool = false

var mouse_skin = preload("res://assets/sprites/UI/Crosshair/mouse_skin.png")

var mouse_change_timer: Timer

func _ready():
	mouse_change_timer = Timer.new()
	add_child(mouse_change_timer)
	mouse_change_timer.timeout.connect(_on_change_timer_timeout)
	
	timeout_timer = Timer.new()
	add_child(timeout_timer)
	timeout_timer.timeout.connect(_on_timeout)
	
	timeout_timer.start(inactive_timer)
	
	if BackgroundState.CLEAN:
		get_tree().change_scene_to_file("res://scenes/World/main.tscn")
		print("clean")
	elif BackgroundState.SEMI:
		semi_cleaning_overlay.play("default")
		print("semi")
	elif BackgroundState.BAD:
		bad_cleaning_overlay.play("default")
		print("bad")

func _process(delta):
	mouse_clean_skin.position = to_local(get_global_mouse_position())
	
	if semi_cleaning_overlay.frame == 6:
		background.play("clean")
		current_state = BackgroundState.CLEAN
		get_tree().change_scene_to_file("res://scenes/World/main.tscn")
	elif bad_cleaning_overlay.frame == 6:
		background.play("semi")
		current_state = BackgroundState.SEMI

func _input(event):
	# Only restart the timer if there's mouse motion or clicks
	if event is InputEventMouseMotion or event.is_action_pressed("click") or event.is_action_released("click"):
		timeout_timer.start(inactive_timer)
	
	if event.is_action_pressed("pause"):
		pauseMenu()
	
	if event.is_action_pressed("click"):
		cleaing = true
		AudioController.play_audio("mouse_change", 10.0)
		mouse_clean_skin.play("sponge_clean")
		
		if BackgroundState.SEMI:
			semi_cleaning_overlay.play("cleaning")
		elif BackgroundState.BAD:
			bad_cleaning_overlay.play("cleaning")
			
		Input.set_custom_mouse_cursor(mouse_skin, Input.CURSOR_ARROW, Vector2(0, 0))
	elif event.is_action_released("click"):
		mouse_clean_skin.play("sponge")
		cleaing = false
		
		if BackgroundState.SEMI:
			semi_cleaning_overlay.stop()
		elif BackgroundState.BAD:
			bad_cleaning_overlay.stop()
		elif BackgroundState.CLEAN:
			get_tree().change_scene_to_file("res://scenes/World/main.tscn")
		
		mouse_change_timer.start(5)

func _on_change_timer_timeout():
	Input.set_custom_mouse_cursor(mouse_release, Input.CURSOR_ARROW, Vector2(0, 0))
	mouse_clean_skin.visible = false
