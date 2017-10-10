extends Node

var action_types = preload ('action_types.gd').new()
var store = preload ('redux.gd').new()

func update_player(state, action):
	if action['type'] == action_types.SET_PLAYER_HEALTH:
		var next_state = store.shallow_copy(state)
		store.shallow_merge(action['params'], next_state)
		return next_state
	return state

