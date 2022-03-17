extends Node2D

var availableCardCount : Dictionary = {}

var popupUI = preload("res://Scenes/UI/PopupUI.tscn")
var fontTRES = preload("res://Fonts/FontNormal.tres")

var nums := []

var slotPageWidth = 5
var slotPageHeight = 3
var slotPageNum = slotPageWidth * slotPageHeight

var cardSlot = preload("res://Scenes/CardSlot.tscn")
var cardNode = preload("res://Scenes/CardNode.tscn")
onready var cardWidth = ListOfCards.cardBackground.get_width()
onready var cardHeight = ListOfCards.cardBackground.get_height()
var hoverScene = preload("res://Scenes/UI/Hover.tscn")
var cardDists = 16

var currentPage := -1 setget setCurrentPage, getCurrentPage
var pages := []

var hasSaved = true

enum SORT_ORDER {TYPE, POWER, TOUGHNESS}
var sortOrder : int = SORT_ORDER.TYPE

var loadedDeckName = ""

func _ready():
	$DeckDisplay.parent = self 
	setCards()

func setCards():
	if Settings.gameMode == Settings.GAME_MODE.NONE:
		for i in range(ListOfCards.cardList.size()):
			if ListOfCards.cardList[i].tier == 1:
				availableCardCount[i] = 4
	else:
		$Menu/DeleteButton.hide()
		$Menu/NewButton.hide()
		$Menu/LoadButton.hide()
	sort()

func clearPages():
	slotViewing = null
	slotReturning = null

	while pages.size() > 0:
		for s in pages[0].get_children():
			s.queue_free()
		pages[0].queue_free()
		pages.erase(pages[0])

func setSortOrder(order : int):
	sortOrder = order
	sort()

func sort():
	clearPages()
	
	var listOfCards := []
	for k in availableCardCount.keys():
		var c = ListOfCards.getCard(k)
		listOfCards.append(c)
	
	var cardsToAdd = []
	if sortOrder == SORT_ORDER.TYPE or sortOrder == SORT_ORDER.POWER or sortOrder == SORT_ORDER.TOUGHNESS:
		for i in Card.CREATURE_TYPE.values():
			for j in Card.CREATURE_TYPE.values():
				if i == 0:
					break
				var typesToComp = []
				if i != 0:
					typesToComp.append(i)
				if j != 0:
					typesToComp.append(j)
					
				var cardsToRemove = []
				for c in listOfCards:
					var hasAll = true
					for t in typesToComp:
						if not c.creatureType.has(t):
							hasAll = false
					for t in c.creatureType:
						if not typesToComp.has(t):
							hasAll = false
					if hasAll:
						cardsToAdd.append(c)
						cardsToRemove.append(c)
				for c in cardsToRemove:
					listOfCards.erase(c)
				
	if sortOrder == SORT_ORDER.POWER or sortOrder == SORT_ORDER.TOUGHNESS:
		for c in cardsToAdd:
			listOfCards.append(c)
		cardsToAdd = []
		while listOfCards.size() > 0:
			var highest = null
			for c in listOfCards:
				if highest == null:
					highest = c
				else:
					var compA
					var compB
					if sortOrder == SORT_ORDER.POWER:
						compA = highest.power
						compB = c.power
					elif sortOrder == SORT_ORDER.TOUGHNESS:
						compA = highest.toughness
						compB = c.toughness
					if compB > compA:
						highest = c
			cardsToAdd.append(highest)
			listOfCards.erase(highest)
				
	var mod
	if cardsToAdd.size() == 0:
		mod = 0
	elif cardsToAdd.size() % slotPageNum == 0:
		mod = slotPageNum
	else:
		mod = cardsToAdd.size() % slotPageNum
		
	var remainder = slotPageNum - mod
	for i in range(remainder):
		cardsToAdd.append(null)
			
	for i in range(cardsToAdd.size() / slotPageNum):
		var page = Node2D.new()
		page.name = "page_" + str(i)
		$PageHolder.add_child(page)
		page.visible = false
		pages.append(page)
		for j in range(slotPageNum):
			var x = j % slotPageWidth
			var y = j / slotPageWidth
			var offX = (x - (slotPageWidth - 1) / 2.0) * (cardWidth + cardDists)
			var offY = (y - (slotPageHeight - 1) / 2.0) * (cardHeight + cardDists*2)
			
			var slot = cardSlot.instance()
			slot.currentZone = CardSlot.ZONES.NONE
			slot.board = self
			page.add_child(slot)
			slot.position = Vector2(offX, offY)
			
			var card = cardsToAdd[i * slotPageNum + j]
			if card != null:
				var cardPlacing = cardNode.instance()
				cardPlacing.card = card
				page.add_child(cardPlacing)
				cardPlacing.global_position = slot.global_position
				slot.cardNode = cardPlacing
				cardPlacing.slot = slot
			
			
						
			if card != null:
				updateSlotCount(slot)
				
	var offL = (-2 - (slotPageWidth - 1) / 2.0) * (cardWidth + cardDists)
	$LArrow.position = Vector2(offL, 30)
	var offR = (slotPageWidth + 1 - (slotPageWidth - 1) / 2.0) * (cardWidth + cardDists)
	$RArrow.position = Vector2(offR, 30)
	
	setCurrentPage(0)
	

func leftArrowPressed():
	setCurrentPage(getCurrentPage() - 1)

func rightArrowPressed():
	setCurrentPage(getCurrentPage() + 1)

func _physics_process(delta):
	slotClicked = false
	
	if slotViewing != null:
		if viewTimer < viewMaxTime:
			viewTimer += delta
			slotViewing.cardNode.global_position = lerp(slotViewing.global_position, $PageHolder.position, viewTimer / viewMaxTime)
			#slotViewing.cardNode.scale.x = cos(abs(2 * PI * viewTimer / viewMaxTime))
			slotViewing.cardNode.scale = lerp(Vector2(1, 1), Vector2(viewScale, viewScale), viewTimer / viewMaxTime)
		else:
			if not is_instance_valid(infoWindow):
				createHoverNode(Vector2(-cardWidth * viewScale * 0.5 * Settings.cardSlotScale, 0), slotViewing.cardNode.card.getHoverData())
	if slotReturning != null:
		if returnTimer < returnMaxTime:
			returnTimer += delta
			if returnTimer > returnMaxTime:
				slotReturning.cardNode.global_position = slotReturning.global_position
				slotReturning.cardNode.scale = Vector2(1, 1)
				slotReturning.cardNode.z_index -= 1
				slotReturning = null
			else:
				slotReturning.cardNode.global_position = lerp($PageHolder.position, slotReturning.global_position, returnTimer / returnMaxTime)
				slotReturning.cardNode.scale = lerp(Vector2(viewScale, viewScale), Vector2(1, 1), returnTimer / returnMaxTime)

func onSlotEnter(slot : CardSlot):
	pass
	
func onSlotExit(slot : CardSlot):
	pass
	
var slotViewing = null
var viewTimer = 0
var viewMaxTime = 0.15
var viewScale = 3
var slotReturning = null
var returnTimer = 0
var returnMaxTime = 0.3
var infoWindow = null
	
func createHoverNode(position : Vector2, text : String):
	var hoverInst = hoverScene.instance()
	hoverInst.z_index = 3
	hoverInst.flipped = true
	add_child(hoverInst)
	hoverInst.global_position = position
	hoverInst.setText(text)
	infoWindow = hoverInst

func removeCard(id : int):
	var slot = null
	for p in pages:
		for s in p.get_children():
			if s is CardSlot and is_instance_valid(s.cardNode):
				if s.cardNode.card.UUID == id:
					slot = s
	updateSlotCount(slot)
	

var slotClicked = false
func onMouseDown(slot : CardSlot, button_index : int):
	if not $SaveDisplay.visible and not $FileDisplay.visible and is_instance_valid(slot.cardNode):
		if button_index == 1:
			var countCheck = true
			for i in $DeckDisplay.data.size():
				if $DeckDisplay.data[i].card.UUID == slot.cardNode.card.UUID:
					countCheck = $DeckDisplay.data[i].count < availableCardCount[slot.cardNode.card.UUID]
					break
			
			if slot.cardNode != null and slotViewing == null and countCheck:
				$DeckDisplay.addCard(slot.cardNode.card.UUID)
				updateSlotCount(slot)
				
		elif button_index == 2:
			if slotViewing == null and slot.cardNode != null:
				slotViewing = slot
				slotViewing.cardNode.z_index += 2
				viewTimer = 0
				slotClicked = true
				
func onMouseUp(slot : CardSlot, button_index : int):
	pass

func updateSlotCount(slot : CardSlot):
	var index = -1
	for i in range($DeckDisplay.data.size()):
		if $DeckDisplay.data[i].card.UUID == slot.cardNode.card.UUID:
			index = i
			break
	if index >= 0:
		slot.get_node("Label").text = str($DeckDisplay.data[index].count) + "/" + str(availableCardCount[slot.cardNode.card.UUID])
	else:
		slot.get_node("Label").text = "0/" + str(availableCardCount[slot.cardNode.card.UUID])

func onLoadPressed():
	if not hasSaved:
		var pop = popupUI.instance()
		pop.init("Unsaved Changes", "You have unsaved changes. Are you sure you want to load a new deck?", [["Yes", self, "onConfirmLoad", [pop]], ["Back", pop, "close", []]])
		add_child(pop)
	else:
		onConfirmLoad()
		
func onSavePressed():
	$SaveDisplay.visible = true
	$SaveDisplay/Background/LineEdit.grab_focus()
	$SaveDisplay/Background/LineEdit.text = loadedDeckName.get_basename()
	$SaveDisplay/Background/LineEdit.caret_position = loadedDeckName.get_basename().length()
	
func onNewPressed():
	if not hasSaved:
		var pop = popupUI.instance()
		pop.init("Unsaved Changes", "You have unsaved changes. Are you sure you want to start a new deck?", [["Yes", self, "onConfirmNew", [pop]], ["Back", pop, "close", []]])
		add_child(pop)
	else:
		onConfirmNew()
	
func onSaveEnter(s : String):
	onFileSaveButtonPressed()
	
func onExitPressed():
	if not hasSaved:
		var pop = popupUI.instance()
		pop.init("Unsaved Changes", "You have unsaved changes. Are you sure you want to exit?", [["Yes", self, "onConfirmExit", [pop]], ["Back", pop, "close", []]])
		add_child(pop)
	else:
		onConfirmExit()
	
func onConfirmNew(popup=null):
	if popup != null:
		popup.close()
	$DeckDisplay.clearData()
	hasSaved = true
	loadedDeckName = ""
	
func onConfirmExit(popup=null):
	if popup != null:
		popup.close()
	
	var error = get_tree().change_scene("res://Scenes/StartupScreen.tscn")
	if error != 0:
		print("Error loading test1.tscn. Error Code = " + str(error))

func onConfirmLoad(popup=null):
	if popup != null:
		popup.close()
		
	$FileDisplay.visible = true
	$FileDisplay/ButtonHolder/Label.text = "Load File"
	
	var files = []
	var dir = Directory.new()
	dir.open(Settings.path)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with(".") and file.ends_with("json"):
			files.append(file)
	dir.list_dir_end()
	
	for c in $FileDisplay/ButtonHolder.get_children():
		if c is Button and c.name != "BackButton":
			$FileDisplay/ButtonHolder.remove_child(c)
			c.queue_free()
	for i in range(files.size()):
		var b = Button.new()
		$FileDisplay/ButtonHolder.add_child(b)
		b.text = str(files[i].get_basename())
		b.set("custom_fonts/font", fontTRES)
		b.connect("pressed", self, "onFileLoadButtonPressed", [files[i]])
		$FileDisplay/ButtonHolder.move_child(b, i+1)
	$FileDisplay/ButtonHolder.set_anchors_and_margins_preset(Control.PRESET_CENTER)
	$FileDisplay/Background.rect_size = $FileDisplay/ButtonHolder.rect_size + Vector2(60, 20)
	$FileDisplay/Background.rect_position = $FileDisplay/ButtonHolder.rect_position - Vector2(30, 10)
		
func onFileLoadBackPressed():
	$FileDisplay.visible = false
	
func onFileLoadButtonPressed(fileName : String):
	print("File ", fileName, " selected")
	
	var dataRead = FileIO.readJSON(Settings.path + fileName)
	var error = Deck.verifyDeck(dataRead)
	print("Deck validity: " + str(error))
	if error == Deck.DECK_VALIDITY_TYPE.VALID:
		$DeckDisplay.clearData()
		for k in dataRead.keys():
			var id = int(k)
			for i in range(int(dataRead[k])):
				$DeckDisplay.addCard(id)
		hasSaved = true
		
		loadedDeckName = fileName
	else:
		print("Deck file is not valid")
		
		var pop = popupUI.instance()
		pop.init("Error Loading Deck", "Error loading " + fileName + "\nop_code=" + str(error) + " : " + Deck.DECK_VALIDITY_TYPE.keys()[error])
		add_child(pop)
		
	onFileLoadBackPressed()
		
func onFileSaveBackPressed():
	$SaveDisplay/Background/LineEdit.text = ""
	$SaveDisplay.visible = false
	
func onFileSaveButtonPressed():
	
	var fileName = $SaveDisplay/Background/LineEdit.text
	
	var error = Deck.verifyDeck($DeckDisplay.getDeckDataAsJSON())
	if error == Deck.DECK_VALIDITY_TYPE.VALID:
		var fileError = FileIO.writeToJSON(Settings.path, fileName, $DeckDisplay.getDeckData())
		if fileError != 0:
			print("ERROR CODE WHEN WRITING TO FILE : " + str(fileError))
			var pop = popupUI.instance()
			pop.init("Error", "File could not be saved")
			add_child(pop)
		else:
			print("Deck successfully saved")
			var pop = popupUI.instance()
			pop.init("Deck Saved")
			add_child(pop)
			hasSaved = true
			loadedDeckName = fileName
	else:
		var pop = popupUI.instance()
		pop.init("Error Verifying Deck", "Error verifying\nop_code=" + str(error) + " : " + Deck.DECK_VALIDITY_TYPE.keys()[error])
		add_child(pop)
	
	onFileSaveBackPressed()
		
var fileToDelete = ""
		
func onDeleteButtonPressed():
	$FileDisplay.visible = true
	$FileDisplay/ButtonHolder/Label.text = "Delete File"
		
	var files = []
	var dir = Directory.new()
	dir.open(Settings.path)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with(".") and file.ends_with("json"):
			files.append(file)
	dir.list_dir_end()
	
	for c in $FileDisplay/ButtonHolder.get_children():
		if c is Button and c.name != "BackButton":
			$FileDisplay/ButtonHolder.remove_child(c)
			c.queue_free()
	for i in range(files.size()):
		var b = Button.new()
		$FileDisplay/ButtonHolder.add_child(b)
		b.text = str(files[i].get_basename())
		b.set("custom_fonts/font", fontTRES)
		b.connect("pressed", self, "onDeleteFileButtonPressed", [files[i]])
		$FileDisplay/ButtonHolder.move_child(b, i+1)
	$FileDisplay/ButtonHolder.set_anchors_and_margins_preset(Control.PRESET_CENTER)
	$FileDisplay/Background.rect_size = $FileDisplay/ButtonHolder.rect_size + Vector2(60, 20)
	$FileDisplay/Background.rect_position = $FileDisplay/ButtonHolder.rect_position - Vector2(30, 10)
	
func onDeleteFileButtonPressed(fileName : String):
	fileToDelete = fileName
	$FileDisplay.visible = false
	var pop = popupUI.instance()
	pop.init("Delete Deck", "Are you sure you want to delete " + fileName, [["Yes", self, "onDeleteConfirmed", [pop]], ["Back", self, "onDeleteBackPressed", [pop]]])
	add_child(pop)
	
func onDeleteConfirmed(popup=null):
	var dir = Directory.new()
	var error = dir.remove(Settings.path + "/" + fileToDelete)
	print(error)
	onDeleteBackPressed(popup)
	
func onDeleteBackPressed(popup=null):
	if popup != null:
		popup.close()
	fileToDelete = ""
	
func deckModified():
	hasSaved = false
	
func setCurrentPage(newPage : int):
	newPage = max(min(newPage, pages.size() - 1), 0)
	pages[currentPage].visible = false
	currentPage = newPage
	pages[newPage].visible = true
	
	$LArrow.visible = currentPage != 0
	$RArrow.visible = currentPage != pages.size() - 1

func getCurrentPage() -> int:
	return currentPage
	
func _input(event):
	if event is InputEventKey and event.is_pressed() and not event.is_echo() and not ($SaveDisplay.visible or $FileDisplay.visible):
		if event.scancode == KEY_A or event.scancode == KEY_LEFT:
			setCurrentPage(getCurrentPage() - 1)
		elif event.scancode == KEY_D or event.scancode == KEY_RIGHT:
			setCurrentPage(getCurrentPage() + 1)
	
	if not slotClicked:
		if event is InputEventMouseButton:
			if event.pressed and (event.button_index == 2):
				if slotViewing != null and slotReturning == null:
					yield(get_tree().create_timer(0.02), "timeout")
					if is_instance_valid(infoWindow):
						infoWindow.close()
					slotReturning = slotViewing
					slotViewing.cardNode.z_index -= 1
					slotViewing = null
					returnTimer = 0
