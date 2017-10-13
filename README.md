# godot_redux

<img src="https://raw.githubusercontent.com/godotengine/godot/master/icon.png" alt="Godot" height="100" width="100"/><img src="https://raw.githubusercontent.com/reactjs/redux/master/logo/logo.png" alt="Redux" height="100" width="100"/>

Redux for Godot is a tool written in GDScript for handling state management. It is completely inspired by the [Redux javascript package](http://redux.js.org).

Working with Godot's scene structure and dynamically typed script language, the challenges of state mutation and organization are similar to those encountered when building a web app in React. Instead of littering all component nodes with game state, which can be unruly and confusing for larger projects, we can consolidate all state into a single store and govern write-access through the use of discrete actions and reducers.

Knowledge about the javascript version of Redux is recommended. Refer to the [Redux javascript docs](http://redux.js.org) for a more detailed reference.

## Usage

### Actions

Actions are dictionary objects sent to the store and are the only source of information for the store. They are sent using the `store.dispatch()` function.

Actions must have a `type` property. Apart from that, any other property related to the action can be included.

### Action creators

Action creators are functions that create and dispatch actions. They are called throughout your game code and serve as interfaces to your store.

### Reducers

Reducers respond to the actions that are dispatched to the store and are responsible for applying the changes needed to the store.

Reducers are pure functions that take 2 parameters: the last known state and an action. It outputs a new state. It is important that the reducer does not mutate the previous state. It must either return the previous state as is (the default case), or create a new dictionary to house the new state. The calculation performed by the reducer must be predictable and repeatable and cannot depend on anything else that may produce a different output given the same inputs.

### Store

The store is the object that glues everything together:
* It holds the game state
* Allows access via `get()`
* Allows state to be updated via `dispatch(action)`
* Registers handlers via `subscribe(target, name)`
* Unregisters handlers via `unsubscribe(target, name)`
