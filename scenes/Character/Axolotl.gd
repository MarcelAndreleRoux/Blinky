extends StaticBody2D

@onready var animation_tree = $AnimationTree
@export var active: bool = false
@export var move_distance: float = 40.0
@export var lerp_speed: float = 1.5
@export var speed_up: bool = false

var transition_timer: Timer
var transition_time: float = 1.0
var transitioning: bool = false
var target_position: Vector2
var original_position: Vector2

func _ready():
	transition_timer = Timer.new()
	add_child(transition_timer)
	transition_timer.timeout.connect(_on_transition_timeout)
	
	original_position = position
	target_position = position
	
	animation_tree.active = true
	Global.clicked.connect(_on_screen_clicked)

func change_speed(toggled_on):
	speed_up = toggled_on

func _process(delta):
	if speed_up:
		animation_tree.set("parameters/TimeScale/scale", 2.0)
	else:
		animation_tree.set("parameters/TimeScale/scale", 1.0)
	
	update_animation_player()
	
	# Smooth movement towards the target position
	if transitioning:
		position = position.lerp(target_position, lerp_speed * delta)

func _on_screen_clicked(state: bool):
	active = state
	if state:
		AxolotlState.on_player_click()

# Handles what happens when the timer ends
func _on_transition_timeout():
	transitioning = false  # Reset flag once transition is complete
	
	var current_state = AxolotlState.current_state
	
	# Transition to IDLE after GOING_UP
	if current_state == AxolotlState.State.GOING_UP:
		AxolotlState.set_state(AxolotlState.State.IDLE)
	
	# Transition to RESTING after GOING_DOWN
	elif current_state == AxolotlState.State.GOING_DOWN:
		AxolotlState.set_state(AxolotlState.State.RESTING)
		target_position = original_position

	update_animation_player()

# Updating the animation tree based on the current state
func update_animation_player():
	var current_state = AxolotlState.current_state

	match current_state:
		AxolotlState.State.IDLE:
			animation_tree["parameters/AnimationNodeStateMachine/conditions/is_idle"] = true
			animation_tree["parameters/AnimationNodeStateMachine/conditions/is_idle_b"] = false
			animation_tree["parameters/AnimationNodeStateMachine/conditions/is_resting"] = false
			animation_tree["parameters/AnimationNodeStateMachine/conditions/is_resting_b"] = false
			animation_tree["parameters/AnimationNodeStateMachine/conditions/is_getting_up"] = false
			animation_tree["parameters/AnimationNodeStateMachine/conditions/is_going_down"] = false
		AxolotlState.State.IDLE_B:
			animation_tree["parameters/AnimationNodeStateMachine/conditions/is_idle_b"] = true
			animation_tree["parameters/AnimationNodeStateMachine/conditions/is_idle"] = false
			animation_tree["parameters/AnimationNodeStateMachine/conditions/is_resting"] = false
			animation_tree["parameters/AnimationNodeStateMachine/conditions/is_resting_b"] = false
			animation_tree["parameters/AnimationNodeStateMachine/conditions/is_getting_up"] = false
			animation_tree["parameters/AnimationNodeStateMachine/conditions/is_going_down"] = false
		AxolotlState.State.RESTING:
			animation_tree["parameters/AnimationNodeStateMachine/conditions/is_resting"] = true
			animation_tree["parameters/AnimationNodeStateMachine/conditions/is_idle"] = false
			animation_tree["parameters/AnimationNodeStateMachine/conditions/is_idle_b"] = false
			animation_tree["parameters/AnimationNodeStateMachine/conditions/is_resting_b"] = false
			animation_tree["parameters/AnimationNodeStateMachine/conditions/is_getting_up"] = false
			animation_tree["parameters/AnimationNodeStateMachine/conditions/is_going_down"] = false
		AxolotlState.State.RESTING_B:
			animation_tree["parameters/AnimationNodeStateMachine/conditions/is_resting_b"] = true
			animation_tree["parameters/AnimationNodeStateMachine/conditions/is_idle"] = false
			animation_tree["parameters/AnimationNodeStateMachine/conditions/is_idle_b"] = false
			animation_tree["parameters/AnimationNodeStateMachine/conditions/is_resting"] = false
			animation_tree["parameters/AnimationNodeStateMachine/conditions/is_getting_up"] = false
			animation_tree["parameters/AnimationNodeStateMachine/conditions/is_going_down"] = false
		AxolotlState.State.GOING_UP:
			animation_tree["parameters/AnimationNodeStateMachine/conditions/is_idle"] = false
			animation_tree["parameters/AnimationNodeStateMachine/conditions/is_idle_b"] = false
			animation_tree["parameters/AnimationNodeStateMachine/conditions/is_resting"] = false
			animation_tree["parameters/AnimationNodeStateMachine/conditions/is_resting_b"] = false
			animation_tree["parameters/AnimationNodeStateMachine/conditions/is_getting_up"] = true
			animation_tree["parameters/AnimationNodeStateMachine/conditions/is_going_down"] = false
			
			if not transitioning:
				transitioning = true  # Set flag to prevent repeated transitions
				target_position = original_position - Vector2(0, move_distance)
				transition_timer.start(transition_time)
		AxolotlState.State.GOING_DOWN:
			animation_tree["parameters/AnimationNodeStateMachine/conditions/is_idle"] = false
			animation_tree["parameters/AnimationNodeStateMachine/conditions/is_idle_b"] = false
			animation_tree["parameters/AnimationNodeStateMachine/conditions/is_resting"] = false
			animation_tree["parameters/AnimationNodeStateMachine/conditions/is_resting_b"] = false
			animation_tree["parameters/AnimationNodeStateMachine/conditions/is_getting_up"] = false
			animation_tree["parameters/AnimationNodeStateMachine/conditions/is_going_down"] = true
			
			if not transitioning:
				transitioning = true
				target_position = original_position + Vector2(0, 9)
				transition_timer.start(transition_time)
