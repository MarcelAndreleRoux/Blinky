extends Node

var animation_chance = 0.2
var check_interval = 5.0

var back_timer_idle: Timer
var back_timer_resting: Timer
var check_timer: Timer

enum State {
	IDLE,
	IDLE_B,
	RESTING,
	RESTING_B,
	GOING_UP,
	GOING_DOWN,
	ACTIVE
}

var current_state: State = State.RESTING

func _ready():
	back_timer_idle = Timer.new()
	back_timer_idle.wait_time = 0.7
	back_timer_idle.one_shot = true
	back_timer_idle.timeout.connect(set_back_to_idle)
	add_child(back_timer_idle)

	back_timer_resting = Timer.new()
	back_timer_resting.wait_time = 1.2
	back_timer_resting.one_shot = true
	back_timer_resting.timeout.connect(set_back_to_resting)
	add_child(back_timer_resting)

	check_timer = Timer.new()
	check_timer.wait_time = check_interval
	check_timer.autostart = true
	check_timer.timeout.connect(decide_alternate_animation)
	add_child(check_timer)

# Sets the new state and prints it
func set_state(new_state: State):
	current_state = new_state
	match new_state:
		State.IDLE:
			print("Axolotl is idle")
		State.IDLE_B:
			print("Axolotl is in idle_b state")
			back_timer_idle.start()
		State.RESTING:
			print("Axolotl is resting")
		State.RESTING_B:
			print("Axolotl is in resting_b state")
			back_timer_resting.start()
		State.GOING_UP:
			print("Axolotl is going up")
		State.GOING_DOWN:
			print("Axolotl is going down")
		State.ACTIVE:
			print("Axolotl is active")

# Called when the player clicks the screen
func on_player_click():
	if current_state == State.RESTING or current_state == State.RESTING_B:
		set_state(State.GOING_UP)
	else:
		set_state(State.IDLE)

# Called when the axolotl has been inactive for a while
func on_inactive_timeout():
	if current_state == State.IDLE or current_state == State.IDLE_B:
		set_state(State.GOING_DOWN)
	else:
		set_state(State.RESTING)

# Transitions back to IDLE from IDLE_B
func set_back_to_idle():
	if current_state == State.IDLE_B:
		set_state(State.IDLE)

# Transitions back to RESTING from RESTING_B
func set_back_to_resting():
	if current_state == State.RESTING_B:
		set_state(State.RESTING)

# Decide whether to play an alternate animation based on chance
func decide_alternate_animation():
	if current_state == State.IDLE or current_state == State.RESTING:
		if randf() < animation_chance:
			if current_state == State.IDLE:
				set_state(State.IDLE_B)
			elif current_state == State.RESTING:
				set_state(State.RESTING_B)
