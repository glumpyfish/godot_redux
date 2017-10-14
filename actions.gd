extends Node

onready var types = get_node('/root/action_types')

func game_set_start_time(time):
	return {
		'type': types.GAME_SET_START_TIME,
		'time': time
	}

func player_set_name(name):
	return {
		'type': types.PLAYER_SET_NAME,
		'name': name
	}

func player_set_health(health):
	return {
		'type': types.PLAYER_SET_HEALTH,
		'health': health
	}

