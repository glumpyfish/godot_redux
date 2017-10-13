extends Node

var action_types = preload ('action_types.gd').new()
var store = preload ('store.gd').new()

func player(state, action):
	if action['type'] == action_types.SET_PLAYER_HEALTH:
		var next_state = store.shallow_copy(state)
		next_state['health'] = action['health']
		return next_state
	return state

