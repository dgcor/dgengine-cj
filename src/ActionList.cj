package dgengine

import std.collection.*

public class ActionList <: Action {
    public ActionList(private let actions!: ArrayList<Action> = ArrayList<Action>()) {}

    public func add(action: Action) {
        actions.append(action)
    }

    public func add(action: ?Action) {
        if (let Some(action) <- action) {
            actions.append(action)
        }
    }

    public func isEmpty(): Bool {
        actions.isEmpty()
    }

    public operator func ()(game: Game): Bool {
        for (action in actions) {
            action(game)
        }
        return true
    }
}
