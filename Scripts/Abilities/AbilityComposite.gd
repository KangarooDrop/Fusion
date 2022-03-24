extends Ability

class_name AbilityComposite

var buffsApplied = 0

func _init(card : Card).("Composite", card, Color.gray, true, Vector2(0, 80)):
	pass

func onEnter(card):
	onEffect()

func onEnterFromFusion(card):
	onEffect()

func onOtherEnter(slot):
	if NodeLoc.getBoard().isOnBoard(self.card):
		onEffect()

func onOtherEnterFromFusion(slot):
	if NodeLoc.getBoard().isOnBoard(self.card):
		onEffect()
	
func onOtherLeave(slot):
	if NodeLoc.getBoard().isOnBoard(self.card):
		card.power -= count
		buffsApplied -= 1

func onEffect():
	card.power -= buffsApplied * count
	buffsApplied = 0
	
	for s in NodeLoc.getBoard().creatures[card.playerID]:
		if is_instance_valid(s.cardNode) and (is_instance_valid(card.cardNode.slot) and s != card.cardNode.slot):
			card.power += count
			buffsApplied += 1

func clone(card : Card) -> Ability:
	var abl = .clone(card)
	abl.buffsApplied = buffsApplied
	return abl
	
func combine(abl : Ability):
	.combine(abl)
	abl.buffsApplied += buffsApplied

func genDescription() -> String:
	return "Gains +" + str(count) + " power for each other creature you control"
