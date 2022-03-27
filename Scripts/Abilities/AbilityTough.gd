extends Ability

class_name AbilityTough

func _init(card : Card).("Tough", card, Color.darkgray, true, Vector2(0, 48)):
	pass

func onBeingAttacked(attacker):
	card.power += count
	card.toughness += count
	card.maxToughness += count

func genDescription() -> String:
	return .genDescription() + "This creature gains +" + str(count) + "/+" + str(count) + " when attacked"
