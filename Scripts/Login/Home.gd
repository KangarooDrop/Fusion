extends Node

func _ready():
	MusicManager.playMainMenuMusic()
	BackgroundFusion.start()
	
	SilentWolf.Auth.connect("sw_session_check_complete", self, "sw_session_check_complete")
	SilentWolf.Auth.auto_login_player()

func sw_session_check_complete(return_value=null):
	if return_value == null:
		$LoadingWindow.hide()
	elif not return_value.success:
		if return_value.error == "no_internet":
			createPopup("Error", "No internet access")
		elif return_value.error == "forbidden":
			createPopup("Error", "Error connecting to the login server. Please, tell Kevin he's dumb")
		else:
			createPopup("Error", "Error loggin in. Please re-enter your information")
		$LoadingWindow.hide()
	else:
		SilentWolf.Players.get_player_data(SilentWolf.Auth.logged_in_player)
		yield(Settings, "_on_validate_player_data_complete")
		get_tree().change_scene("res://Scenes/StartupScreen.tscn")

func _on_RegisterButton_pressed():
	get_tree().change_scene("res://Scenes/Login/Register.tscn")

func _on_LoginButton_pressed():
	get_tree().change_scene("res://Scenes/Login/Login.tscn")

func _on_ExitButton_pressed():
	get_tree().quit()

func createPopup(title : String, desc : String, options = null):
	var pop = MessageManager.createPopup(title, desc, [])
	if options == null:
		options = pop.GET_CLOSE_BUTTON()
	pop.setButtons(options)
