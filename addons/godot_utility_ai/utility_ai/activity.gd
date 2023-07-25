## An activity is something an AI-controlled unit can choose to do. 
## Activities are picked based on considerations. Considerations 
## modify the rank and weight of an activity. Based on rank and 
## weight an activity is picked and executed. Only one activity is
## active at a time. 
class_name Activity
extends Node

## Emitted once when this activity has been picked.
signal activity_begins()

## Emitted repeatedly every frame while this activity is picked.
signal activity_process(delta:float)

## Emitted repeatedly every physics frame while this activity is picked.
signal activity_physics_process(delta:float)

## Emitted once when another activity has been picked and this activity should end.
signal activity_ends()

## The considerations we use for this activity
var _considerations:Array[Consideration] = []
## The consideration context we use for this activity
var _consideration_context:ConsiderationContext

var _run_on_start:Array[Callable] = []

var _is_running:bool = false

var is_runnning:bool = false:
	get:
		return _is_running

func _init():
	_consideration_context = ConsiderationContext.new(self)

func _ready():
	# don't run the callbacks unless this activity is picked
	process_mode = Node.PROCESS_MODE_DISABLED
	set_process(false)
	set_physics_process(false)

	# Get all children which are considerations and store them for later use.
	for child in get_children():
		if child is Consideration:
			_considerations.append(child)
	
## Considers the utility of this activity and stores the result in the given
## decision context.
func consider(entity:Node, context:DecisionContext):
	for consideration in _considerations:
		consideration.consider(entity, _consideration_context)
		# if after this consideration we already know we won't take this
		# action, we can break out early
		if _consideration_context.will_not_be_taken:
			break	
	
	_run_on_start = _consideration_context.apply_results_to(context)
	
func _process(delta):
	activity_process.emit(delta)

func _physics_process(delta):
	activity_physics_process.emit(delta)
	
func start(entity:Node):
	print("Starting activity ", name)
	
	_is_running = true
	for action in _run_on_start:
		action.call()
		
	_run_on_start.clear()

	# unpause the node if anyone is interested.
	process_mode = Node.PROCESS_MODE_INHERIT if activity_process.get_connections().size() > 0 or activity_physics_process.get_connections().size() > 0 else Node.PROCESS_MODE_DISABLED

	# enable the callbacks if needed
	if activity_process.get_connections().size() > 0:
		set_process(true)
	if activity_physics_process.get_connections().size() > 0:
		set_physics_process(true)

	activity_begins.emit()

func stop(entity:Node):
	print("Stopping activity ", name)

	activity_ends.emit()
	_is_running = false
	# stop the node
	process_mode = Node.PROCESS_MODE_DISABLED
	set_process(false)
	set_physics_process(false)
