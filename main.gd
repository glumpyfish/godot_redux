extends Node

var actions = preload ('actions.gd').new()
var reducers = preload ('reducers.gd').new()
onready var store = preload ('store.gd').new()

func _ready():
	store.create(
		[{'name': 'player', 'instance': reducers}],
		[{'name': '_on_store_changed', 'instance': self}]
	)
	set_player_health(100)

func _on_store_changed(name, prev_state, state):
	print (store.get())

func set_player_health(value):
	store.dispatch(actions.set_player_health(value))

