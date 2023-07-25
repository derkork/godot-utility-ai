## Picks a target from an influence map depending on wheter
## there is a line of sight from the current entity to the 
## target.
class_name LineOfSightTargetPicker2D
extends Consideration


enum DecisionCriterium {
	INFLUENCE,
	DISTANCE
}

enum TargetExtremum {
	HIGHEST,
	LOWEST
}

## The influence map which should be used. Use a NodeExpression to refer to a node
## directly or a BlackboardExpression to pick a node from the blackboard.
@export var influence_map:BaseExpression = NodeExpression.new()

## Based on which criterium should the picker pick a target?
@export var criterium:DecisionCriterium = DecisionCriterium.INFLUENCE

## Whether the picker should pick the target with the lowest or highest value.
@export var which:TargetExtremum = TargetExtremum.HIGHEST

## The radius within which the picker should look for a suitable target.
@export var radius:BaseExpression = FloatExpression.new()


