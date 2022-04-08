extends Ability

class_name TextGreyGoo

var perm = load("res://Scripts/Abilities/AbilityPermeation.gd")

func _init(card : Card).("Grey Goo", card, Color.lightgray, false, Vector2(0, 0)):
	pass

func genDescription(subCount = 0) -> String:
	return .genDescription() + "A 1/1 mech with " + str(perm.new(null))
