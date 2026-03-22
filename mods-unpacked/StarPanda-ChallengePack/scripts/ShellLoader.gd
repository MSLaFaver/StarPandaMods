extends Object

const id = "StarPanda-ChallengePack"
const CPGameConfig = preload("res://mods-unpacked/StarPanda-ChallengePack/util/CPGameConfig.gd")

var modePhrases := {
	CPGameConfig.GameMode.QUANTITY: ["Some of them are live.", "Now this is a real game."],
	CPGameConfig.GameMode.HIDDEN: ["You won't know their real number.", "Now this is a real game."]
}
var dealerFirstMessageShown := false
var rnd = RandomNumberGenerator.new()
var lastTurn := 1

func LoadShells(chain: ModLoaderHookChain):
	var shellLoader = chain.reference_object
	
	var current_mode = ModLoader.get_node(id).config_data.mode
	
	# ORIGINAL CODE
	shellLoader.camera.BeginLerp("enemy")
	if (not shellLoader.roundManager.shellLoadingSpedUp):
		await shellLoader.get_tree().create_timer(.8, false).timeout
	await(shellLoader.DealerHandsGrabShotgun())
	await shellLoader.get_tree().create_timer(.2, false).timeout
	shellLoader.animator_shotgun.play("grab shotgun_pointing enemy")
	await shellLoader.get_tree().create_timer(.45, false).timeout
	# END ORIGINAL CODE
	
	await _cpIntroductionPhrases(shellLoader, current_mode)
	
	# ORIGINAL CODE
	var numberOfShells = shellLoader.roundManager.roundArray[shellLoader.roundManager.currentRound].amountBlank \
		+ shellLoader.roundManager.roundArray[shellLoader.roundManager.currentRound].amountLive
	# END ORIGINAL CODE
	if (current_mode == CPGameConfig.GameMode.HIDDEN):
		numberOfShells = 8
		
	# ORIGINAL CODE
	for i in range(numberOfShells):
		shellLoader.speaker_loadShell.play()
		shellLoader.animator_dealerHandRight.play("load single shell")
		if(shellLoader.roundManager.shellLoadingSpedUp):
			await shellLoader.get_tree().create_timer(.17, false).timeout
		else:
			await shellLoader.get_tree().create_timer(.32, false).timeout
	shellLoader.animator_dealerHandRight.play("RESET")
	shellLoader.dealerAI.Speaker_HandCrack()
	if (shellLoader.roundManager.shellLoadingSpedUp):
		await shellLoader.get_tree().create_timer(.17, false).timeout
	else:
		await shellLoader.get_tree().create_timer(.42, false).timeout
	#INTRODUCTION DIALOGUE
	if (shellLoader.roundManager.roundArray[shellLoader.roundManager.currentRound].hasIntroductoryText):
		shellLoader.dialogue.ShowText_Forever(shellLoader.introductionDialogues[0])
		await shellLoader.get_tree().create_timer(1.9, false).timeout
		shellLoader.dialogue.ShowText_Forever(shellLoader.introductionDialogues[1])
		await shellLoader.get_tree().create_timer(3, false).timeout
		shellLoader.dialogue.ShowText_Forever(shellLoader.introductionDialogues[2])
		await shellLoader.get_tree().create_timer(3, false).timeout
		shellLoader.dialogue.ShowText_Forever(shellLoader.introductionDialogues[3])
		await shellLoader.get_tree().create_timer(3, false).timeout
		shellLoader.dialogue.ShowText_Forever(shellLoader.introductionDialogues[4])
		await shellLoader.get_tree().create_timer(3, false).timeout
		shellLoader.dialogue.ShowText_Forever(shellLoader.introductionDialogues[5])
		await shellLoader.get_tree().create_timer(3.7, false).timeout
		shellLoader.dialogue.ShowText_Forever(shellLoader.introductionDialogues[6])
		await shellLoader.get_tree().create_timer(3.7, false).timeout
		shellLoader.dialogue.ShowText_Forever(shellLoader.introductionDialogues[7])
		await shellLoader.get_tree().create_timer(3.7, false).timeout
		shellLoader.dialogue.ShowText_Forever(shellLoader.introductionDialogues[8])
		await shellLoader.get_tree().create_timer(2.5, false).timeout
		shellLoader.roundManager.playerData.hasReadIntroduction = true
		shellLoader.dialogue.HideText()
	#RACK SHOTGUN, PLACE ON TABLE
	#speaker_rackShotgun.play()
	shellLoader.animator_shotgun.play("enemy rack shotgun start")
	await shellLoader.get_tree().create_timer(.8, false).timeout
	shellLoader.animator_shotgun.play("enemy put down shotgun")
	shellLoader.DealerHandsDropShotgun()
	# END ORIGINAL CODE
	
	_cpResolveNextTurn(shellLoader)
	
func _cpIntroductionPhrases(shellLoader: ShellLoader, current_mode: int):
	if (current_mode == CPGameConfig.GameMode.DEFAULT):
		# ORIGINAL CODE (from LoadShells)
		if (shellLoader.roundManager.playerData.numberOfDialogueRead < 3):	
			if (shellLoader.diaindex == shellLoader.loadingDialogues.size()):
				shellLoader.diaindex = 0
			var stringshow
			if (shellLoader.diaindex == 0):
				stringshow = tr("SHELL INSERT1")
			if (shellLoader.diaindex == 1):
				stringshow = tr("SHELL INSERT2")
			shellLoader.dialogue.ShowText_ForDuration(stringshow, 3)
			shellLoader.diaindex += 1
			await shellLoader.get_tree().create_timer(3, false).timeout
			shellLoader.roundManager.playerData.numberOfDialogueRead += 1
		# END ORIGINAL CODE
		return
		
	var phrases = modePhrases[current_mode]
	var phrasesAmount = phrases.size()
	
	# TODO: Replace 3 with actual phrase amount
	if (shellLoader.roundManager.playerData.numberOfDialogueRead < 3):
		if (shellLoader.diaindex == phrasesAmount):
			shellLoader.diaindex = 0
		shellLoader.dialogue.ShowText_ForDuration(phrases[shellLoader.diaindex], 3)
		shellLoader.diaindex += 1
		await shellLoader.get_tree().create_timer(3, false).timeout
		shellLoader.roundManager.playerData.numberOfDialogueRead += 1

func _cpResolveNextTurn(shellLoader: ShellLoader):
	var turn_mode = ModLoader.get_node(id).config_data.turn
	if (turn_mode == CPGameConfig.TurnMode.ALWAYS_FIRST):
		await _cpTurnPlayer(shellLoader)
		return
	
	var next_turn = 1 if (lastTurn == 0) else 0
	if (turn_mode == CPGameConfig.TurnMode.RANDOM):
		next_turn = rnd.randi_range(0, 1)
	
	if (next_turn == 0):
		await _cpTurnPlayer(shellLoader)
	else:
		await _cpTurnDealer(shellLoader)
	lastTurn = next_turn
		
func _cpTurnPlayer(shellLoader: ShellLoader) -> void:
	# ORIGINAL CODE (from LoadShells)
	shellLoader.camera.BeginLerp("home")
	#ALLOW INTERACTION
	shellLoader.roundManager.playerCurrentTurnItemArray = []
	await shellLoader.get_tree().create_timer(.6, false).timeout
	shellLoader.perm.SetStackInvalidIndicators()
	shellLoader.cursor.SetCursor(true, true)
	shellLoader.perm.SetIndicators(true)
	shellLoader.perm.SetInteractionPermissions(true)
	shellLoader.roundManager.SetupDeskUI()
	# END ORIGINAL CODE

func _cpTurnDealer(shellLoader: ShellLoader) -> void:
	await shellLoader.get_tree().create_timer(.6, false).timeout
	if (not dealerFirstMessageShown):
		shellLoader.dialogue.ShowText_Forever("I'll be the first")
		await shellLoader.get_tree().create_timer(1.9, false).timeout
		shellLoader.dialogue.HideText()
		dealerFirstMessageShown = true
	shellLoader.dealerAI.BeginDealerTurn()
