package dgengine

import cjsfml.audio.*
import encoding.json.*

public func parseAudioTimeSpan(elem: JsonValue) {
    TimeSpan(
        offset: getTimeUKey(elem, "offset"),
        length: getTimeUKey(elem, "length")
    )
}
