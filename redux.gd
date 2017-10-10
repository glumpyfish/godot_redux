extends Node

var _store = {}

signal store_changed(prev_state, state)

func create(reducers, callbacks, instance):
	for reducer in reducers:
		if not _store.has(instance):
			_store[instance] = {}
		_store[instance][reducer] = {}
	if callbacks != null:
		for callback in callbacks:
			connect('store_changed', instance, callback)

func dispatch(action, instance):
	for reducer in _store[instance].keys():
		var state = shallow_copy(_store[instance][reducer])
		var next_state = reducer.call_func(state, action)
		if state != next_state:
			shallow_merge(next_state, _store[instance][reducer])
			emit_signal('store_changed', state, next_state)

func shallow_merge(src_dict, dest_dict):
	for i in src_dict.keys():
		dest_dict[i] = src_dict[i]
	return dest_dict

func shallow_copy(dict):
	return shallow_merge(dict, {})

