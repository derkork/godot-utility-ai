## A decision context which is used to record the current decision
## process.
class_name DecisionContext
extends RefCounted

const INITIAL_MIN_RANK = -1000000

## The minimum weight a decision must have in order to be considered
var _min_weight:float = 0.001

var _min_rank:int = INITIAL_MIN_RANK

## The minimum rank an activity must have in order to be considered. Can be
## checked by the activity to skip running consideration if it would be 
## pointless anyways.
var min_rank:int:
	get: return _min_rank	

## The highest stratum of activities from which a winner will be picked.
## Key is the activity, value is the weight.
var _highest_stratum:Dictionary = {}

## Records a decision. This is intended to be called by activities when
## they have decided whether to run.
func record_decision_result(activity:Activity, rank:int, weight:float):
	if weight <= _min_weight:
		return # ignore activities that are not having at least a minimum weight
	
	if rank > _min_rank:
		# we have a new rank that is bigger than the largest rank we had so far
		# in this case the current highest stratum is eliminated and we
		# will create a new stratum
		_highest_stratum.clear()
		_min_rank = rank
		
		
	if rank >= _min_rank: 
		# we have an activity in the currently highest stratum, so add it
		_highest_stratum[activity] = weight

		
## Picks a winner from the highest stratum of activities and returns it. Will
## reset the object so it can be re-used for another poll.
##
## If no activities are available, returns null. Winner is picked by weighted random
## so each activity in the highest stratum can win but activities with a higher 
## weight have a higher chance of winning. 	
func pick_winner_or_null() -> Activity:
	# if we have no choices at all, bail out
	if _highest_stratum.is_empty():
		return null
		
	# if we only have a single choice, this is the automatic winner
	if _highest_stratum.size() == 1:
		var result = _highest_stratum.keys()[0]
		clear()
		return result
		
		
	# We accumulate the weight of all activities and take note of the 
	# accumulated sum for each activity. We then roll a random number
	# between 0 and the total weight and then pick the first activity
	# which has an accumulated weight of greater than the the rolled value.
	# Two notes:
	# - there are potentially faster algorithms but this one is simple
	#   and we usually should only have a handful of choices so
	#   there is not much to gain by using a more complex algorithm (e.g.
	#   the alias method).
	# - this code relies on the fact that dictionaries in godot return
	#   their keys in repeatable, predictable order.
	var total_weight:float = 0.0
	for activity in _highest_stratum.keys():
		total_weight += _highest_stratum[activity]
		# note that this is destructive, but we will clear the stratum anyways
		# so no harm done
		_highest_stratum[activity] = total_weight 
		
	# pick a random
	var pick = randf_range(0, total_weight)
	
	var result:Activity 
	for activity in _highest_stratum.keys():
		if _highest_stratum[activity] >= pick:
			result = activity
			break
	
	clear()
	return result
	
	
func clear():
	_highest_stratum.clear()
	_min_rank = INITIAL_MIN_RANK
