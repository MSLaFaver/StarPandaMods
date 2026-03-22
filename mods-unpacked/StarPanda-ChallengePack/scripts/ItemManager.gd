extends Object

const id = "StarPanda-ChallengePack"

func SetupItemSteal(chain: ModLoaderHookChain):
	chain.execute_next_async()
	ModLoader.get_node(id).cp_steal_start.emit()
	
func RevertItemSteal(chain: ModLoaderHookChain):
	chain.execute_next_async()
	ModLoader.get_node(id).cp_steal_end.emit()

func RevertItemSteal_Timeout(chain: ModLoaderHookChain):
	chain.execute_next_async()
	ModLoader.get_node(id).cp_steal_end.emit()
