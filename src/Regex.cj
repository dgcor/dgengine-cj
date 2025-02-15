package dgengine

import std.regex.{Matcher, Regex as StdRegex}

public class Regex {
    private var m_regex: ?StdRegex = None

    public init() {}

    public init(pattern: String) {
        try {
            if (pattern.isEmpty() == false) {
                m_regex = StdRegex(pattern)
            }
        } catch (_: Exception) {}
    }

    public prop isValid: Bool {
        get() {
            m_regex.isSome()
        }
    }

    public func matcher(str: String): Bool {
        try {
            if (let Some(regex) <- m_regex) {
                return regex.matcher(str).fullMatch().isSome()
            }
        } catch (_: Exception) {}
        return false
    }

    public static func matchPattern(pattern: String, str: String): Bool {
        try {
            return Regex(pattern).matcher(str)
        } catch (_: Exception) {}
        return false
    }
}
