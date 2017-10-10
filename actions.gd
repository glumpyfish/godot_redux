extends Node

var types = preload ('action_types.gd').new()

func set_player_health(value):
	return {
		'type': types.SET_PLAYER_HEALTH,
		'params': {'player_health': value}
	}

