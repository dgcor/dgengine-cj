package dgengine

import encoding.json.*

public func parsePanelAddDrawable(elem: JsonValue): ?Action {
    ActPanelAddDrawable(getStringCharKey(elem, "id"), getStringCharKey(elem, "drawable"))
}
