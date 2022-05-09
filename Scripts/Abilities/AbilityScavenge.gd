extends Ability

class_name AbilityScavenge

func _init(card : Card).("Scavenge", card, Color.darkgray, true, Vector2(16, 96)):
	pass

func onOtherDeath(slot):
	if NodeLoc.getBoard().isOnBoard(card) and card.playerID == slot.playerID:
		addToStack("onEffect", [])

func onEffect(params):
	card.power += count
	card.toughness += count

func genDescription(subCount = 0) -> String:
	return .genDescription() + "When another creature you control dies, gain +" + str(count) + "/+" + str(count)
