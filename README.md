# Redux for Godot

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

## Example

A good way to start with redux is by planning what your store will look like. The store is a dictionary of dictionaries where the first level keys (`game`, `players`, `gui`, `stats`, `dungeon1`) are reducers. Here is an example that shows some possible ideas:
```
{
    'game': {
        'paused': false
    }
    'players': {
        'player1': {
            'id': 'player1',
            'name': 'Jane',
            'location_x': 0,
            'location_y': 0,
            'moving': true
        }
    },
    'gui': {
        'loading': false,
    },
    'stats': {
        'timer_start_time': 0,
        'timer_running': false
    }
    'dungeon1': {
        'found_key': true,
        'found_map': false,
        'found_compass': false
    }
}
```
It is best if the data is normalized (as flat as possible). Often the tree is only 2 or 3 levels deep.

Once you have a basic store schema, you can plan some action types. A common practice is to create constants and make them equal to strings of the same name. The naming scheme tends to be NOUN_VERB.
```
const GAME_PAUSE = 'GAME_PAUSE'
const GAME_UNPAUSE = 'GAME_UNPAUSE'
const PLAYER_MOVE_START = 'PLAYER_MOVE_START'
const PLAYER_MOVE_UPDATE = 'PLAYER_MOVE_UPDATE'
const PLAYER_MOVE_END = 'PLAYER_MOVE_END'
const TIMER_START = 'TIMER_START'
const TIMER_STOP = 'TIMER_STOP'
```
Creating the actions then allows us to specify what information each action needs.
```
function game_pause():
    return { 'type': GAME_PAUSE }

function game_unpause():
    return { 'type': GAME_UNPAUSE }

function player_move_start(id):
    return { 'type': PLAYER_MOVE_START, 'id': id }

function player_move_update(id, vect2D):
    return { 'type': PLAYER_MOVE_UPDATE, 'id': id, 'newX': vect2D.x, 'newY': vect2D.y }

function player_move_end(id):
    return { 'type': PLAYER_MOVE_END, 'id': id }

function timer_start(time):
    return { 'type': TIMER_START, 'time': time }

function timer_stop():
    return { 'type': TIMER_STOP }
```
Reducers can now be defined. They receive the previous state (for that particular reducer) and the action. The return value must be either the same state (which should always be the default case), or a completely new dictionary object for the given action. Even if the new state is very similar to the old state, the new state must be a separate copy.  If the state needs to be complex, we can use strategic shallow copies to avoid churn from too much object cloning.
```
function game(state, action):
    if action['type'] == GAME_PAUSE:
        return {'paused': true}
    return state

function players(state, action):
    if action['type'] == PLAYER_MOVE_START:
        var player_state = store.shallow_copy(state[action['id']])
        player_state['moving'] = true
        var new_state = store.shallow_copy(state)
        new_state[action['id']] = player_state
        return new_state
    if action['type'] == PLAYER_MOVE_UPDATE:
        var player_state = store.shallow_copy(state[action['id']])
        player_state['location_x'] = action['x']
        player_state['location_y'] = action['y']
        var new_state = store.shallow_copy(state)
        new_state[action['id']] = player_state
        return new_state
    if action['type'] == PLAYER_MOVE_END:
        var player_state = store.shallow_copy(state[action['id']])
        player_state['moving'] = false
        var new_state = store.shallow_copy(state)
        new_state[action['id']] = player_state
        return new_state
    return state

function stats(state, action):
    if action['type'] == TIMER_START:
        var new_state = store.shallow_copy(state)
        new_state['timer_start_time'] = action['time']
        new_state['timer_running'] = true
        return new_state
    if action['type'] == TIMER_END:
        var new_state = store.shallow_copy(state)
        new_state['timer_running'] = false
        return new_state
    return state
```
And finally, the action creators can be created throughout your code. They are functions responsible for firing off the actions to the store.
```
function on_pause_button_click():
    var is_paused = store.get()['game']['paused']
    if is_paused:
        store.dispatch(actions.game_unpause())
        store.dispatch(actions.timer_start(OS.get_unix_time()))
    else:
        store.dispatch(actions.game_pause())
        store.dispatch(actions.timer_stop())
```

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

## Authors

* **Kenny Au** <<glumpyfish@gmail.com>>

## License

This project is licensed under the MIT License - see the [LICENSE.txt](LICENSE.txt) file for details.
