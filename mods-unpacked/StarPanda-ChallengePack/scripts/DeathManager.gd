extends Object

const id = "StarPanda-ChallengePack"

func _ready(chain: ModLoaderHookChain):
	chain.execute_next_async()
	ModLoader.get_node(id).apply_patches()

func MainDeathRoutine(chain: ModLoaderHookChain):
	chain.execute_next_async()
	ModLoader.get_node(id).cp_death.emit()
