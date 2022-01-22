extends Ability

class_name AbilityComposite

func _init(card : Card).("Composite", "Gains +1/+0 for each other creature you control", card, Color.gray, true):
	pass

func onEnter(board, slot):
	for s in board.creatures[card.cardNode.slot.playerID]:
		if is_instance_valid(s.cardNode) and s != slot:
			card.power += count

func onOtherEnter(board, slot):
	card.power += count
	
func onLeave(board):
	for s in board.creatures[card.cardNode.slot.playerID]:
		if is_instance_valid(s.cardNode) and s != card.cardNode.slot:
			card.power -= count
	
func onOtherLeave(board, slot):
	card.power -= count
	
