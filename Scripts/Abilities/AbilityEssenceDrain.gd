extends AbilityETB

class_name AbilityEssenceDrain

func _init(card : Card).("Essence Drain", card, Color.darkgray, true, Vector2(0, 0)):
	pass

func onApplied(slot):
	addToStack("onEffect", [count - timesApplied])

func onEffect(params):
	var n = 0
	for s in NodeLoc.getBoard().boardSlots:
		if is_instance_valid(s.cardNode) and s.cardNode.card != null and (not is_instance_valid(card.cardNode) or not is_instance_valid(card.cardNode.slot) or s != card.cardNode.slot):
			s.cardNode.card.power -= params[0]
			s.cardNode.card.toughness -= params[0]
			s.cardNode.card.maxToughness -= params[0]
			n += 1
			
	card.power += params[0] * n

func genDescription(subCount = 0) -> String:
	var strCount = str(count - subCount)
	return .genDescription() + "When this creature is played, all other creatures get -" + strCount + "/-" + strCount + ". Gain +" + strCount + " power for each creature affected"
