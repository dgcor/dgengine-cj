package dgengine

import encoding.json.*

public func parseActionSet(game: Game, elem: JsonValue): ?Action {
    ActActionSet(
        getStringCharKey(elem, "id"),
        getActionKey(game, elem, "action")
    )
}
