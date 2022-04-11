extends Control

func _ready():
	MusicManager.playMainMenuMusic()
	Settings.gameMode = Settings.GAME_MODE.NONE
	$SettingsPage/VBox/Shaders/SelectShaderButton.text = ShaderHandler.currentShader.get_file().get_basename().capitalize()
	
	BackgroundFusion.start()

func onDeckEditPressed():
	var error = get_tree().change_scene("res://Scenes/DeckEditor.tscn")
	if error != 0:
		print("Error loading test1.tscn. Error Code = " + str(error))
	
func onPracticePressed():
	var error = get_tree().change_scene("res://Scenes/Networking/LobbyPractice.tscn")
	if error != 0:
		print("Error loading test1.tscn. Error Code = " + str(error))
	
func onLobbyPressed():
	Settings.gameMode = Settings.GAME_MODE.LOBBY_PLAY
	var error = get_tree().change_scene("res://Scenes/Networking/Lobby.tscn")
	if error != 0:
		print("Error loading test1.tscn. Error Code = " + str(error))

func onDraftPressed():
	Settings.gameMode = Settings.GAME_MODE.LOBBY_DRAFT
	var error = get_tree().change_scene("res://Scenes/Networking/DraftLobby.tscn")
	if error != 0:
		print("Error loading test1.tscn. Error Code = " + str(error))
	
func onSettingsPressed():
	$VBoxContainer.visible = false
	$SettingsPage.visible = true
	
func onExitPressed():
	get_tree().quit()

func onSettingsClose():
	$VBoxContainer.visible = true

func onPlayPressed():
	$VBoxContainer.visible = false
	$VBoxContainer2.visible = true

func onBackPressed():
	$VBoxContainer.visible = true
	$VBoxContainer2.visible = false
	$CreditsLabel.hide()
	$BackButton.hide()

func onCreditsPressed():
	$VBoxContainer.visible = false
	$CreditsLabel.show()
	$BackButton.show()

func _input(event):
	if event is InputEventKey and event.is_pressed() and not event.is_echo() and event.scancode == KEY_ESCAPE:
		if $CreditsLabel.visible or $VBoxContainer2.visible:
			onBackPressed()
		elif $SettingsPage/FileDisplay.visible:
			$SettingsPage.onShaderBackButtonPressed()
		elif $SettingsPage.visible:
			$SettingsPage.onBackPressed()
