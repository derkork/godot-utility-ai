class_name ConsiderationContext

## The current rank this consideration result has.
var _current_rank:int = DecisionContext.INITIAL_MIN_RANK
## The current multiplier for this consideration result.
var _current_multiplier:float = 1.0
## How many consideration have been scored until now.
var _scored_considerations:int = 0

## The activity which this consideration context works with.
var _activity:Activity = null

func _init(activity:Activity):
	_activity = activity
	

## Checks if after the currently executed considerations we already know
## that the activity will not be taken and we can skip running additional
## considerations.
var will_not_be_taken:bool:
	get: return _current_multiplier <= 0

## Records the result of a consideration.
func record_consideration_result(min_rank:int, multiplier:float):
	_scored_considerations += 1
	_current_rank = max(_current_rank, min_rank)
	_current_multiplier *= multiplier
	
## Applies the results of this context to the given decision context and 
## resets this context so it can be reused.	
func apply_results_to(decision_context:DecisionContext):
	# TODO: provide a compensation factor for when we have a lot of considerations
	# as these will pull down the multiplier.	
	decision_context.record_decision_result(_activity, _current_rank, _current_multiplier)
	
	_current_rank = DecisionContext.INITIAL_MIN_RANK
	_current_multiplier = 1.0
	_scored_considerations = 0
