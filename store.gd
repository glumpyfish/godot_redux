extends Node

var _state = {}
var _reducers = {}

signal state_changed(name, state)

func create(reducers, callbacks = null):
	for reducer in reducers:
		var name = reducer['name']
		if not _state.has(name):
			_state[name] = {}
		if not _reducers.has(name):
			_reducers[name] = funcref(reducer['instance'], name)
	if callbacks != null:
		for callback in callbacks:
			subscribe(callback['instance'], callback['name'])

func subscribe(target, method):
	connect('state_changed', target, method)

func unsubscribe(target, method):
	disconnect('state_changed', target, method)

func dispatch(action):
	for name in _reducers.keys():
		var state = _state[name]
		var next_state = _reducers[name].call_func(state, action)
		if state != next_state:
			shallow_merge(next_state, state)
			emit_signal('state_changed', name, state)

func get():
	return _state

func shallow_copy(dict):
	return shallow_merge(dict, {})

func shallow_merge(src_dict, dest_dict):
	for i in src_dict.keys():
		dest_dict[i] = src_dict[i]
	return dest_dict

