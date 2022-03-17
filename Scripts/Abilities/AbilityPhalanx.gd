extends Ability

class_name AbilityPhalanx

var buffsApplied = 0

func _init(card : Card).("Phalanx", card, Color.darkgray, true, Vector2(16, 48)):
	pass

func onEnter(board, slot):
	for i in range(count - buffsApplied):
		onEffect()
		buffsApplied += 1

func onEnterFromFusion(board, slot):
	for i in range(count - buffsApplied):
		onEffect()
		buffsApplied += 1

func onOtherEnter(board, slot):
	for s in card.cardNode.slot.getNeighbors():
		if s == slot:
			s.cardNode.card.power += count
			s.cardNode.card.toughness += count

func onEffect():
	for s in card.cardNode.slot.getNeighbors():
		if is_instance_valid(s.cardNode):
			s.cardNode.card.power += 1
			s.cardNode.card.toughness += 1

func onLeave(board):
	if is_instance_valid(card.cardNode):
		for s in card.cardNode.slot.getNeighbors():
			if is_instance_valid(s.cardNode):
				s.cardNode.card.power -= count
				s.cardNode.card.toughness -= count

func onOtherLeave(board, slot):
	if is_instance_valid(slot.cardNode):
		if slot in card.cardNode.slot.getNeighbors():
			slot.cardNode.card.power -= count
			slot.cardNode.card.toughness -= count
	
	
func clone(card : Card) -> Ability:
	var abl = .clone(card)
	abl.buffsApplied = buffsApplied
	return abl

func combine(abl : Ability):
	.combine(abl)
	abl.buffsApplied += buffsApplied

func genDescription() -> String:
	return "Adjacent creatures get +" + str(count) + "/+" + str(count)
