extends Node

onready var actions = get_node('/root/actions')
onready var reducers = get_node('/root/reducers')
onready var store = get_node('/root/store')

func _ready():
	store.create([
		{'name': 'game', 'instance': reducers},
		{'name': 'player', 'instance': reducers}
	], [
		{'name': '_on_store_changed', 'instance': self}
	])
	store.dispatch(actions.game_set_start_time(OS.get_unix_time()))
	store.dispatch(actions.player_set_name('Me'))
	store.dispatch(actions.player_set_health(100))

func _on_store_changed(name, prev_state, state):
	print (store.get())

