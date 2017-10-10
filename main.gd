extends Node

var actions = preload ('actions.gd').new()
var reducers = preload ('reducers.gd').new()
onready var store = preload ('redux.gd').new()

func _ready():
	store.create(
		[funcref(reducers, 'update_player')],
		['_on_store_changed'],
		self
	)
	set_player_health(100)

func _on_store_changed(prev_state, state):
	print (state)

func set_player_health(value):
	store.dispatch(actions.set_player_health(value), self)

