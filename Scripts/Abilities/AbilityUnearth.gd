extends AbilityETB

class_name AbilityUnearth

var graveCards = []

func _init(card : Card).("Unearth", card, Color.darkgray, true, Vector2(0, 0)):
	pass

func onApplied(slot):
	addToStack("onEffect", [self.clone(card), card.playerID])

func onEffect(params):
	NodeLoc.getBoard().getSlot(params[0], params[1])

func slotClicked(slot : CardSlot):
	var board = NodeLoc.getBoard()
#	if slot == null:
#		for p in NodeLoc.getBoard().players:
#			if p.UUID == card.playerID:
#				slot = p.hand.slots[randi() % p.hand.slots.size()]
#				break
	
	if slot.currentZone == CardSlot.ZONES.GRAVE:
		var g = board.graveDisplays[slot.playerID]
		if g.slots.size() > 0:
			slot = g.slots[g.slots.size()-1]
	
	if slot.currentZone == CardSlot.ZONES.GRAVE_CARD:
		if not graveCards.has(slot.cardNode.card):
			SoundEffectManager.playSelectSound()
			graveCards.append(slot.cardNode.card)
		else:
			SoundEffectManager.playUnselectSound()
			graveCards.erase(slot.cardNode.card)
		
		var total = 0
		for k in board.graveCards.keys():
			total += board.graveCards[k].size()
		
		if graveCards.size() >= total or graveCards.size() >= count - timesApplied:
			for card in graveCards:
				for k in board.graveCards.keys():
					var g = board.graveCards[k]
					for i in range(g.size()):
						if g[i] == card:
							board.removeCardFromGrave(k, i)
							break
				
				for p in board.players:
					if p.UUID == self.card.playerID:
						p.hand.addCardToHand([card, true, true])
						break
			
			NodeLoc.getBoard().endGetSlot()

func genDescription(subCount = 0) -> String:
	var string = " card"
	if count - timesApplied > 1:
		string + " cards"
	return .genDescription() + "When this creature is played, choose " + str(count - timesApplied) + string + " in any " + str(TextScrapyard.new(null)) +". Add that card to your hand"
