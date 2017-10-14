# godot_redux

<img src="https://raw.githubusercontent.com/godotengine/godot/master/icon.png" alt="Godot" height="100" width="100"/><img src="https://raw.githubusercontent.com/reactjs/redux/master/logo/logo.png" alt="Redux" height="100" width="100"/>

Redux for Godot is a tool written in GDScript for handling state management. It is completely inspired by the [Redux javascript package](http://redux.js.org).

Working with Godot's scene structure and dynamically typed script language, the challenges of state mutation and organization are similar to those encountered when building a web app in React.
Instead of littering all component nodes with game state, which can be unruly and confusing for larger projects, we can consolidate all state into a single store and govern write-access through the use of discrete actions and reducers.

Using the redux architecture also allows for some interesting features:
* Saving and loading saved games becomes trivial.
* Time travel (i.e. undo/redo actions).

Knowledge about the javascript version of Redux is recommended. Refer to the [Redux javascript docs](http://redux.js.org) for a more detailed reference.

## Usage

The following files must be added to "Scene > Project Settings > AutoLoad":
* `store.gd`
* `action_types.gd`
* `actions.gd`
* `reducers.gd`

## Basics

### Actions

Actions are dictionary objects sent to the store and are the only source of information for the store. They are sent using the `store.dispatch()` function.

Actions must have a `type` property. Apart from that, any other property related to the action can be included.

```
func example_action(value1, value2):
    return {
        'type': 'EXAMPLE_ACTION_TYPE',
        'key1': value1,
        'key2': value2
    }
```

### Reducers

Reducers respond to the actions that are dispatched to the store and are responsible for applying the changes needed to the store.

Reducers are pure functions that take 2 parameters: the last known state and an action. It outputs a new state. It is important that the reducer does not mutate the previous state. It must either return the previous state as is (the default case), or create a new dictionary to house the new state. The calculation performed by the reducer must be predictable and repeatable and cannot depend on anything else that may produce a different output given the same inputs.

```
func example_reducer(state, action):
    if action['type'] == 'EXAMPLE_ACTION_TYPE':
        var next_state = util.shallow_copy(state)
        next_state['key1'] = action['key1']
        next_state['key2'] = action['key2']
        return next_state
    return state
```

### Subscribers

Callback functions can be specified at the time of store creation or individually at a later time. They are called whenever the state is changed. Due to the static nature of Godot's signal definitions, subscribers will receive all state changes throughout the app. To help with this, the reducer name is passed to the callback so it can choose to respond to the appropriate changes.

### Store

The store is the object that glues everything together:
* It holds the game state
* Allows access via `get()`
* Allows state to be updated via `dispatch(action)`
* Registers handlers via `subscribe(target, name)`
* Unregisters handlers via `unsubscribe(target, name)`

## API

### store.get()

No parameters.

Returns: Dictionary containing entire state.

### store.create(reducers, [callbacks])

Parameter | Required | Description | Example
--- | --- | --- | ---
`reducers` | Yes | An array of dictionaries, each with `name` and `instance` keys. | `[{ 'name': 'function_name', 'instance': obj }]`
`callbacks` | No | An array of dictionaries, each with `name` and `instance` keys. | `[{ 'name': 'function_name', 'instance': obj }]`

Returns: Nothing.

### store.dispatch(action)

Parameter | Required | Description | Example
--- | --- | --- | ---
`action` | Yes | A dictionary containing `type` key. | `{ 'type': 'ACTION_TYPE' }`

Returns: Nothing

### store.subscribe(target, method)

Parameter | Required | Description | Example
--- | --- | --- | ---
`target` | Yes | Object containing the callback function. | `self`
`method` | Yes | String of the callback function name. | `'callback_function'`

Returns: Nothing

### store.unsubscribe(target, method)

Parameter | Required | Description | Example
--- | --- | --- | ---
`target` | Yes | Object containing the callback function. | `self`
`method` | Yes | String of the callback function name. | `'callback_function'`

Returns: Nothing

### store.shallow_copy(dict)

Parameter | Required | Description | Example
--- | --- | --- | ---
`dict` | Yes | Dictionary to be cloned. | `{ 'key1' : 'value1' }`

Returns: A copy of the dictionary, however only the first level of keys are cloned.

### store.shallow_merge(src_dict, dest_dict)

Parameter | Required | Description | Example
--- | --- | --- | ---
`src_dict` | Yes | Dictionary to merge. | `{ 'key' : 'new_value' }`
`dest_dict` | Yes | Dictionary affected by merge. | `{ 'key' : 'old_value' }`

Returns: Nothing. `dest_dict` is mutated and now has merge changes. Only the first level of keys is copied. Later levels are referenced.
