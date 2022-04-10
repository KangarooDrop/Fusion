extends Node

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

enum SORT_ORDER {TYPE, POWER, HEALTH, RARITY, NAME}
var sortOrder : int = SORT_ORDER.TYPE

var loadedDeckName = ""

var popups := []

func _ready():
	MusicManager.playDeckEditorMusic()
	
	$CenterControl/DeckDisplay.parent = self
	setCards()
	
	for k in SORT_ORDER.keys():
		$CenterControl/SortNode/HBoxContainer/SortButton.add_item(k.capitalize())
	
	$CenterControl/SortNode/HBoxContainer/SortButton.theme = Theme.new()
	$CenterControl/SortNode/HBoxContainer/SortButton.theme.default_font = fontTRES
	
	$CenterControl/SortNode/HBoxContainer/SortButton.select(0)
	setSortOrder(0)

func setCards():
	if Settings.gameMode == Settings.GAME_MODE.NONE:
		for i in range(ListOfCards.cardList.size()):
			if ListOfCards.cardList[i].tier == 1:
				if ListOfCards.cardList[i].rarity == Card.RARITY.COMMON:
					availableCardCount[i] = 4
				elif ListOfCards.cardList[i].rarity == Card.RARITY.LEGENDARY:
					availableCardCount[i] = 1
				elif ListOfCards.cardList[i].rarity == Card.RARITY.VANGUARD:
					availableCardCount[i] = 1
					
	else:
		$CenterControl/Menu/DeleteButton.hide()
		$CenterControl/Menu/NewButton.hide()
		$CenterControl/Menu/LoadButton.hide()

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
	
	#SORT BY: TYPE   = TYPE,  RARITY, NAME
	#SORT BY: POWER  = POWER, RARITY, TYPE, NAME
	#SORT BY: TOUGH  = TOUGH, RARITY, TYPE, NAME
	#SORT BY: RARITY = RARITY, TYPE,  NAME
	
	var cardsToAdd = sortArray(listOfCards, sortOrder)
	
	if sortOrder == SORT_ORDER.TYPE:
		for i in range(cardsToAdd.size()):
			var newPage = []
			var r = sortArray(cardsToAdd[i], SORT_ORDER.RARITY)
			for ra in r:
				for t in sortArray(ra, SORT_ORDER.NAME):
					newPage.append(t[0])
			cardsToAdd[i] = newPage
	elif sortOrder == SORT_ORDER.POWER or sortOrder == SORT_ORDER.HEALTH:
		for i in range(cardsToAdd.size()):
			var newPage = []
			for r in sortArray(cardsToAdd[i], SORT_ORDER.RARITY):
				for t in sortArray(r, SORT_ORDER.TYPE):
					for n in sortArray(t, SORT_ORDER.NAME):
						newPage.append(n[0])
			cardsToAdd[i] = newPage
	elif sortOrder == SORT_ORDER.RARITY:
		for i in range(cardsToAdd.size()):
			var newPage = []
			for t in sortArray(cardsToAdd[i], SORT_ORDER.TYPE):
				for n in sortArray(t, SORT_ORDER.NAME):
					newPage.append(n[0])
			cardsToAdd[i] = newPage
	elif sortOrder == SORT_ORDER.NAME:
		var newPage = []
		for n in cardsToAdd:
			newPage.append(n[0])
		cardsToAdd = [newPage]
		
	
	var n = 0
	while n < cardsToAdd.size():
		if cardsToAdd[n].size() > slotPageNum:
			var p1 = []
			var p2 = []
			for i in range(cardsToAdd[n].size()):
				if i < slotPageNum:
					p1.append(cardsToAdd[n][i])
				else:
					p2.append(cardsToAdd[n][i])
			cardsToAdd.remove(n)
			cardsToAdd.insert(n, p2)
			cardsToAdd.insert(n, p1)
		n += 1
	
	for k in cardsToAdd:
		var mod
		if k.size() == 0:
			mod = 0
		elif k.size() % slotPageNum == 0:
			mod = slotPageNum
		else:
			mod = k.size() % slotPageNum
		var remainder = slotPageNum - mod
		
		for i in range(remainder):
			k.append(null)
	
	for i in range(cardsToAdd.size()):
		var page = Node2D.new()
		page.name = "page_" + str(i)
		$CenterControl/PageHolder.add_child(page)
		page.visible = false
		pages.append(page)
		for j in range(slotPageNum):
			var x = j % slotPageWidth
			var y = j / slotPageWidth
			var offX = (x - (slotPageWidth - 1) / 2.0) * (cardWidth + cardDists)
			var offY = (y - (slotPageHeight - 1) / 2.0) * (cardHeight + cardDists*2)
			
			var slot = cardSlot.instance()
			slot.currentZone = CardSlot.ZONES.NONE
			page.add_child(slot)
			slot.position = Vector2(offX, offY)
			
			var card = cardsToAdd[i][j]
			if card != null:
				var cardPlacing = cardNode.instance()
				cardPlacing.z_index = 0
				cardPlacing.card = card
				page.add_child(cardPlacing)
				cardPlacing.global_position = slot.global_position
				slot.cardNode = cardPlacing
				cardPlacing.slot = slot
				
				updateSlotCount(slot)
	
	var offL = (-2 - (slotPageWidth - 1) / 2.0) * (cardWidth + cardDists)
	$CenterControl/LArrow.position = Vector2(offL, 30)
	var offR = (slotPageWidth + 1 - (slotPageWidth - 1) / 2.0) * (cardWidth + cardDists) + 8
	$CenterControl/RArrow.position = Vector2(offR, 30)
	
	setCurrentPage(0)

static func sortArray(listOfCards : Array, sortOrder : int) -> Array:
	var cardPages := {}
	
	for c in listOfCards:
		if c.tier == 1:
			var key = 0
			if sortOrder == SORT_ORDER.POWER:
				key = -c.power
			elif sortOrder == SORT_ORDER.HEALTH:
				key = -c.toughness
			elif sortOrder == SORT_ORDER.TYPE:
				for t in c.creatureType:
					key |= 1 << t
				key += (c.creatureType.size() - 1) * 10000
			elif sortOrder == SORT_ORDER.RARITY:
				key = -c.rarity
			elif sortOrder == SORT_ORDER.NAME:
				key = c.name
			
			if not cardPages.has(key):
				cardPages[key] = [c]
			else:
				cardPages[key].append(c)
	
	var cardsToAdd := []
	while cardPages.size() > 0:
		var lowest = cardPages.keys()[0]
		for i in range(1, cardPages.keys().size()):
			if cardPages.keys()[i] < lowest:
				lowest = cardPages.keys()[i]
		cardsToAdd.append(cardPages[lowest])
		cardPages.erase(lowest)
	
	return cardsToAdd

func leftArrowPressed():
	setCurrentPage(getCurrentPage() - 1)

func rightArrowPressed():
	setCurrentPage(getCurrentPage() + 1)

func _physics_process(delta):
	slotClicked = false
	
	if slotViewing != null:
		if viewTimer < viewMaxTime:
			viewTimer += delta
			slotViewing.cardNode.global_position = lerp(slotViewing.global_position, $CenterControl.rect_global_position, viewTimer / viewMaxTime)
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
				slotReturning.cardNode.global_position = lerp($CenterControl.rect_global_position, slotReturning.global_position, returnTimer / returnMaxTime)
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
	hoverInst.closeChildrenFirst = true
	hoverInst.z_index = 3
	hoverInst.flipped = true
	$CenterControl.add_child(hoverInst)
	hoverInst.position = position
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
	if not $CenterControl/SaveDisplay.visible and not $CenterControl/FileDisplay.visible and is_instance_valid(slot.cardNode):
		if button_index == 1:
			var countCheck = true
			for i in $CenterControl/DeckDisplay.data.size():
				if $CenterControl/DeckDisplay.data[i].card.UUID == slot.cardNode.card.UUID:
					countCheck = $CenterControl/DeckDisplay.data[i].count < availableCardCount[slot.cardNode.card.UUID]
					break
			
			if slot.cardNode != null and slotViewing == null and countCheck:
				$CenterControl/DeckDisplay.addCard(slot.cardNode.card.UUID)
				updateSlotCount(slot)
				
		elif button_index == 2:
			if slotViewing == null and slotReturning == null and slot.cardNode != null and slot.get_parent().visible:
				slotViewing = slot
				slotViewing.cardNode.z_index += 2
				viewTimer = 0
				slotClicked = true
				$CenterControl/DeckDisplay.closeDeckDisplayHover(true)
				
func onMouseUp(slot : CardSlot, button_index : int):
	pass

func updateSlotCount(slot : CardSlot):
	var index = -1
	for i in range($CenterControl/DeckDisplay.data.size()):
		if $CenterControl/DeckDisplay.data[i].card.UUID == slot.cardNode.card.UUID:
			index = i
			break
	if index >= 0:
		slot.get_node("Label").text = str($CenterControl/DeckDisplay.data[index].count) + "/" + str(availableCardCount[slot.cardNode.card.UUID])
	else:
		slot.get_node("Label").text = "0/" + str(availableCardCount[slot.cardNode.card.UUID])

func onLoadPressed():
	if not hasSaved:
		var pop = popupUI.instance()
		pop.init("Unsaved Changes", "You have unsaved changes. Are you sure you want to load a new deck?", [["Yes", self, "onConfirmLoad", [pop]], ["Back", self, "closePopupUI", [pop]]])
		$CenterControl.add_child(pop)
		pop.options[1].grab_focus()
		popups.append(pop)
	else:
		onConfirmLoad()
		
func onSavePressed():
	$CenterControl/SaveDisplay.visible = true
	$CenterControl/SaveDisplay/Background/LineEdit.grab_focus()
	$CenterControl/SaveDisplay/Background/LineEdit.text = loadedDeckName.get_basename()
	$CenterControl/SaveDisplay/Background/LineEdit.caret_position = loadedDeckName.get_basename().length()
	
func onNewPressed():
	if not hasSaved:
		var pop = popupUI.instance()
		pop.init("Unsaved Changes", "You have unsaved changes. Are you sure you want to start a new deck?", [["Yes", self, "onConfirmNew", [pop]], ["Back", self, "closePopupUI", [pop]]])
		$CenterControl.add_child(pop)
		pop.options[1].grab_focus()
		popups.append(pop)
	else:
		onConfirmNew()
	
func onSaveEnter(s : String):
	onFileSaveButtonPressed()
	
func onExitPressed():
	if not hasSaved:
		var pop = popupUI.instance()
		pop.init("Unsaved Changes", "You have unsaved changes. Are you sure you want to exit?", [["Yes", self, "onConfirmExit", [pop]], ["Back", self, "closePopupUI", [pop]]])
		$CenterControl.add_child(pop)
		pop.options[1].grab_focus()
		popups.append(pop)
	else:
		onConfirmExit()

func closePopupUI(popup=null):
	if popup != null:
		popups.erase(popup)
		popup.close()

func onConfirmNew(popup=null):
	if popup != null:
		popups.erase(popup)
		popup.close()
	$CenterControl/DeckDisplay.clearData()
	hasSaved = true
	loadedDeckName = ""
	
func onConfirmExit(popup=null):
	if popup != null:
		popups.erase(popup)
		popup.close()
	
	var error = get_tree().change_scene("res://Scenes/StartupScreen.tscn")
	if error != 0:
		print("Error loading test1.tscn. Error Code = " + str(error))

func onConfirmLoad(popup=null):
	if popup != null:
		popups.erase(popup)
		popup.close()
		
	$CenterControl/FileDisplay.visible = true
	$CenterControl/FileDisplay/ButtonHolder/Label.text = "Load File"
	
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
	
	for c in $CenterControl/FileDisplay/ButtonHolder.get_children():
		if c is Button and c.name != "BackButton":
			$CenterControl/FileDisplay/ButtonHolder.remove_child(c)
			c.queue_free()
	for i in range(files.size()):
		var b = Button.new()
		$CenterControl/FileDisplay/ButtonHolder.add_child(b)
		b.text = str(files[i].get_basename())
		b.set("custom_fonts/font", fontTRES)
		b.connect("pressed", self, "onFileLoadButtonPressed", [files[i]])
		$CenterControl/FileDisplay/ButtonHolder.move_child(b, i+1)
	$CenterControl/FileDisplay/ButtonHolder.set_anchors_and_margins_preset(Control.PRESET_CENTER)
	$CenterControl/FileDisplay/Background.rect_size = $CenterControl/FileDisplay/ButtonHolder.rect_size + Vector2(60, 20)
	$CenterControl/FileDisplay/Background.rect_position = $CenterControl/FileDisplay/ButtonHolder.rect_position - Vector2(30, 10)
	
	var chs = $CenterControl/FileDisplay/ButtonHolder.get_children()
	for c in chs.duplicate():
		if not c is Button:
			chs.erase(c)
	for i in range(chs.size()):
		chs[i].focus_neighbour_left = "../" + chs[i].name
		chs[i].focus_neighbour_right = "../" + chs[i].name
		if i == 0:
			chs[i].focus_neighbour_top = "../" + chs[i].name
		else:
			chs[i].focus_neighbour_top = "../" + chs[i-1].name
		if i == chs.size() - 1:
			chs[i].focus_neighbour_bottom = "../" + chs[i].name
		else:
			chs[i].focus_neighbour_bottom = "../" + chs[i+1].name
		
	chs[0].grab_focus()
		
func onFileLoadBackPressed():
	$CenterControl/FileDisplay.visible = false
	
func onFileLoadButtonPressed(fileName : String):
	print("File ", fileName, " selected")
	
	var dataRead = FileIO.readJSON(Settings.path + fileName)
	var error = Deck.verifyDeck(dataRead)
	print("Deck validity: " + str(error))
	if error == Deck.DECK_VALIDITY_TYPE.VALID:
		$CenterControl/DeckDisplay.clearData()
		for dat in dataRead.keys():
			for k in dataRead[dat].keys():
				var id = int(k)
				for i in range(int(dataRead[dat][k])):
					$CenterControl/DeckDisplay.addCard(id)
					
					for p in pages:
						for c in p.get_children():
							if c is CardSlot and is_instance_valid(c.cardNode):
								updateSlotCount(c)
		hasSaved = true
		
		loadedDeckName = fileName
	else:
		print("Deck file is not valid")
		
		var pop = popupUI.instance()
		pop.init("Error Loading Deck", "Error loading " + fileName + "\nop_code=" + str(error) + " : " + Deck.DECK_VALIDITY_TYPE.keys()[error], [["Close", self, "closePopupUI", [pop]]])
		$CenterControl.add_child(pop)
		pop.options[0].grab_focus()
		popups.append(pop)
		
	onFileLoadBackPressed()
		
func onFileSaveBackPressed():
	$CenterControl/SaveDisplay/Background/LineEdit.text = ""
	$CenterControl/SaveDisplay.visible = false
	
func onFileSaveButtonPressed():
	
	var fileName = $CenterControl/SaveDisplay/Background/LineEdit.text
	
	var error = Deck.verifyDeck($CenterControl/DeckDisplay.getDeckDataAsJSON())
	if error == Deck.DECK_VALIDITY_TYPE.VALID:
		var fileError = FileIO.writeToJSON(Settings.path, fileName, $CenterControl/DeckDisplay.getDeckData())
		if fileError != 0:
			print("ERROR CODE WHEN WRITING TO FILE : " + str(fileError))
			var pop = popupUI.instance()
			pop.init("Error", "File could not be saved", [["Close", self, "closePopupUI", [pop]]])
			$CenterControl.add_child(pop)
			pop.options[0].grab_focus()
			popups.append(pop)
		else:
			print("Deck successfully saved")
			var pop = popupUI.instance()
			pop.init("Deck Saved", "", [["Close", self, "closePopupUI", [pop]]])
			$CenterControl.add_child(pop)
			hasSaved = true
			loadedDeckName = fileName
			pop.options[0].grab_focus()
			popups.append(pop)
	else:
		var pop = popupUI.instance()
		pop.init("Error Verifying Deck", "Error verifying\nop_code=" + str(error) + " : " + Deck.DECK_VALIDITY_TYPE.keys()[error], [["Close", self, "closePopupUI", [pop]]])
		$CenterControl.add_child(pop)
		pop.options[0].grab_focus()
		popups.append(pop)
	
	onFileSaveBackPressed()
		
var fileToDelete = ""
		
func onDeleteButtonPressed():
	$CenterControl/FileDisplay.visible = true
	$CenterControl/FileDisplay/ButtonHolder/Label.text = "Delete File"
		
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
	
	for c in $CenterControl/FileDisplay/ButtonHolder.get_children():
		if c is Button and c.name != "BackButton":
			$CenterControl/FileDisplay/ButtonHolder.remove_child(c)
			c.queue_free()
	for i in range(files.size()):
		var b = Button.new()
		$CenterControl/FileDisplay/ButtonHolder.add_child(b)
		b.text = str(files[i].get_basename())
		b.set("custom_fonts/font", fontTRES)
		b.connect("pressed", self, "onDeleteFileButtonPressed", [files[i]])
		$CenterControl/FileDisplay/ButtonHolder.move_child(b, i+1)
	$CenterControl/FileDisplay/ButtonHolder.set_anchors_and_margins_preset(Control.PRESET_CENTER)
	$CenterControl/FileDisplay/Background.rect_size = $CenterControl/FileDisplay/ButtonHolder.rect_size + Vector2(60, 20)
	$CenterControl/FileDisplay/Background.rect_position = $CenterControl/FileDisplay/ButtonHolder.rect_position - Vector2(30, 10)
	
	var chs = $CenterControl/FileDisplay/ButtonHolder.get_children()
	for c in chs.duplicate():
		if not c is Button:
			chs.erase(c)
	for i in range(chs.size()):
		chs[i].focus_neighbour_left = "../" + chs[i].name
		chs[i].focus_neighbour_right = "../" + chs[i].name
		if i == 0:
			chs[i].focus_neighbour_top = "../" + chs[i].name
		else:
			chs[i].focus_neighbour_top = "../" + chs[i-1].name
		if i == chs.size() - 1:
			chs[i].focus_neighbour_bottom = "../" + chs[i].name
		else:
			chs[i].focus_neighbour_bottom = "../" + chs[i+1].name
		
	chs[0].grab_focus()
	
func onDeleteFileButtonPressed(fileName : String):
	fileToDelete = fileName
	$CenterControl/FileDisplay.visible = false
	var pop = popupUI.instance()
	pop.init("Delete Deck", "Are you sure you want to delete " + fileName, [["Yes", self, "onDeleteConfirmed", [pop]], ["Back", self, "onDeleteBackPressed", [pop]]])
	$CenterControl.add_child(pop)
	pop.options[1].grab_focus()
	popups.append(pop)
	
func onDeleteConfirmed(popup=null):
	var dir = Directory.new()
	var error = dir.remove(Settings.path + "/" + fileToDelete)
	print(error)
	onDeleteBackPressed(popup)
	
func onDeleteBackPressed(popup=null):
	if popup != null:
		popups.erase(popup)
		popup.close()
	fileToDelete = ""
	
func deckModified():
	hasSaved = false
	
func setCurrentPage(newPage : int):
	if pages.size() == 0:
		return
	newPage = max(min(newPage, pages.size() - 1), 0)
	
	if slotViewing != null and currentPage != newPage:
		if is_instance_valid(infoWindow):
			infoWindow.close(true)
		slotViewing.cardNode.global_position = slotViewing.global_position
		slotViewing.cardNode.scale = Vector2(1, 1)
		slotViewing.cardNode.z_index -= 1
		slotViewing = null
	
	if currentPage >= 0 and currentPage < pages.size():
		pages[currentPage].visible = false
	currentPage = newPage
	pages[newPage].visible = true
	
	$CenterControl/LArrow.visible = currentPage != 0
	$CenterControl/RArrow.visible = currentPage != pages.size() - 1

func getCurrentPage() -> int:
	return currentPage
	
func _input(event):
	if event is InputEventKey and event.is_pressed() and not event.is_echo() and not ($CenterControl/SaveDisplay.visible or $CenterControl/FileDisplay.visible) and popups.size() == 0:
		if Input.is_key_pressed(KEY_CONTROL):
			if event.scancode == KEY_S:
				onSavePressed()
			elif event.scancode == KEY_N:
				onNewPressed()
			elif event.scancode == KEY_O:
				onLoadPressed()
			elif event.scancode == KEY_DELETE:
				onDeleteButtonPressed()
		else:
			if event.scancode == KEY_A or event.scancode == KEY_LEFT:
				leftArrowPressed()
			elif event.scancode == KEY_D or event.scancode == KEY_RIGHT:
				rightArrowPressed()
	
	if event is InputEventKey and event.is_pressed() and not event.is_echo() and event.scancode == KEY_ESCAPE:
		if $CenterControl/SaveDisplay.visible:
			onFileSaveBackPressed()
		elif $CenterControl/FileDisplay.visible:
			onFileLoadBackPressed()
		elif popups.size() > 0:
			popups[popups.size()-1].close()
			popups.remove(popups.size()-1)
		else:
			onExitPressed()
	
	if not slotClicked:
		if event is InputEventMouseButton:
			if event.pressed and (event.button_index == 2):
				if is_instance_valid(slotViewing) and slotReturning == null:
					yield(get_tree().create_timer(0.02), "timeout")
					if is_instance_valid(slotViewing) and slotReturning == null:
						if is_instance_valid(infoWindow) and infoWindow.spawnedWindows.size() > 0:
							infoWindow.close()
						else:
							infoWindow.close(true)
							slotReturning = slotViewing
							slotViewing.cardNode.z_index -= 1
							slotViewing = null
							returnTimer = 0

