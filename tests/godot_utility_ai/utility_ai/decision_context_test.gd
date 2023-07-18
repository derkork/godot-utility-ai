extends GdUnitTestSuite

var _under_test:DecisionContext 


func before_test():
	_under_test = DecisionContext.new()
	
	
func test_highest_rank_wins():
	var activity1 = auto_free(Activity.new())
	var activity2 = auto_free(Activity.new())
	var activity3 = auto_free(Activity.new())
	
	# WHEN:
	# i insert activities that have different ranks
	_under_test.record_decision_result(activity1, 5, 0.1)
	_under_test.record_decision_result(activity2, 2, 0.6)
	_under_test.record_decision_result(activity3, 12, 0.05)
	
	# THEN:
	var winner := _under_test.pick_winner_or_null()
	# the activity with the highest rank wins
	assert_object(winner).is_same(activity3)


func test_highest_probability_wins_most_often():
	var activity1 = auto_free(Activity.new())
	var activity2 = auto_free(Activity.new())
	
	var activity1_won:int = 0
	var activity2_won:int = 0
	var total_tries:int = 1000
	# WHEN: i run 1000 cycles of
	for i in total_tries:
		# insert two activities with same rank and 
		_under_test.record_decision_result(activity1, 2, 0.3)
		_under_test.record_decision_result(activity2, 2, 0.7)
		
		var winner = _under_test.pick_winner_or_null()
		if winner == activity1:
			activity1_won += 1
		if winner == activity2:
			activity2_won += 1
			
	# THEN:
	# one of the activities has won every time
	assert_int(activity1_won + activity2_won).is_equal(total_tries)
	# activity1 has won in roughly 30% of the cases (+/- 10%)
	assert_float(float(activity1_won) / float(total_tries)).is_equal_approx(0.3, 0.1)
	# activity2 has won in roughly 70% of the cases (+/- 10%)
	assert_float(float(activity2_won) / float(total_tries)).is_equal_approx(0.7, 0.1)
	
			
