extends Node
# Boilerplate from https://www.gdquest.com/tutorial/godot/design-patterns/finite-state-machine/
# Generic state machine. Initializes states and delegates engine callbacks
# (_physics_process, _unhandled_input) to the active state.

# Emitted when transitioning to a new state.
signal transitioned(state_name)

# The current active state. At the start of the game, we get the `initial_state`.
@onready var state:State = $Wandering
@onready var navigation_agent = get_parent().get_node("NavigationAgent2D")

func _ready():
	# The state machine assigns itself to the State objects' state_machine property.
	for child in get_children():
		if child is State:
			child.state_machine = self
	state.enter()


func _process(delta):
	state.update(delta)


func _physics_process(delta):
	state.physics_update(delta)

# This function calls the current state's exit() function, then changes the active state,
# and calls its enter function.
# It optionally takes a `msg` dictionary to pass to the next state's enter() function.
func transition_to(target_state_name, msg: Dictionary = {}):
	# Safety check, you could use an assert() here to report an error if the state name is incorrect.
	# We don't use an assert here to help with code reuse. If you reuse a state in different state machines
	# but you don't want them all, they won't be able to transition to states that aren't in the scene tree.
	if not has_node(target_state_name):
		return
	
	#print("transitioning to ", target_state_name)
	state.exit()
	state = get_node(target_state_name)
	state.enter(msg)
	emit_signal("transitioned", state.name)
