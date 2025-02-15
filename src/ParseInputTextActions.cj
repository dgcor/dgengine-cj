package dgengine

import encoding.json.*

public func parseInputTextClick(elem: JsonValue): ?Action {
    ActInputTextClick(getStringCharKey(elem, "id"))
}
