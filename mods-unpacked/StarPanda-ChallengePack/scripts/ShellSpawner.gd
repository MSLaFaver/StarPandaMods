extends Object

const id = "StarPanda-ChallengePack"
const CPGameConfig = preload("res://mods-unpacked/StarPanda-ChallengePack/util/CPGameConfig.gd")

func SpawnShells(chain: ModLoaderHookChain, numberOfShells : int, numberOfLives : int, numberOfBlanks : int, shufflingArray : bool):
	var shellSpawner = chain.reference_object
	
	var config_data = ModLoader.get_node(id).config_data
	
	var current_mode = config_data.mode
	var shuffle_mode = config_data.shuffle
	var needShuffle = shufflingArray if (shuffle_mode == CPGameConfig.ShuffleMode.YES) else false;
	
	chain.execute_next_async([numberOfShells, numberOfLives, numberOfBlanks, needShuffle])
	
	if (current_mode != CPGameConfig.GameMode.DEFAULT):
		shellSpawner.roundManager.playerData.skippingShellDescription = true
	if (current_mode == CPGameConfig.GameMode.QUANTITY):
		_cpRecolorShells(shellSpawner.spawnedShellObjectArray)
		
func MainShellRoutine(chain: ModLoaderHookChain):
	var shellSpawner = chain.reference_object
	
	var shuffleRound = shellSpawner.roundManager.roundArray[shellSpawner.roundManager.currentRound].insertingInRandomOrder
	var shuffle_mode = ModLoader.get_node(id).config_data.shuffle
	var needShuffle = shuffleRound if (shuffle_mode == CPGameConfig.ShuffleMode.YES) else false;
	
	if not needShuffle:
		shellSpawner.roundManager.roundArray[shellSpawner.roundManager.currentRound].insertingInRandomOrder = false
	chain.execute_next_async()
		
func PlayLatchSound(chain: ModLoaderHookChain):
	var current_mode = ModLoader.get_node(id).config_data.mode
	if (current_mode == CPGameConfig.GameMode.HIDDEN):
		return
	chain.execute_next_async()
	
func PlayAudioIndicators(chain: ModLoaderHookChain):	
	var current_mode = ModLoader.get_node(id).config_data.mode
	if (current_mode == CPGameConfig.GameMode.HIDDEN):
		return
	chain.execute_next_async()

func _cpRecolorShells(spawnedShellObjectArray):
	for shell in spawnedShellObjectArray:
		var branch = shell.get_child(0)
		branch.mesh.set_surface_override_material(1, branch.mat_blank)
