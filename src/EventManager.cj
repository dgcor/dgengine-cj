package dgengine

import std.collection.*

public class EventManager {
    private var m_events = LinkedList<Action>()

    public func addBack(action: Action): Unit {
        m_events.append(action)
    }

    public func addFront(action: Action): Unit {
        m_events.prepend(action)
    }

    public func addBack(action: ?Action): Unit {
        if (let Some(action) <- action) {
            m_events.append(action)
        }
    }

    public func addFront(action: ?Action): Unit {
        if (let Some(action) <- action) {
            m_events.prepend(action)
        }
    }

    public func exists(id: String): Bool {
        if (id.isEmpty() == false) {
            for (evt in m_events) {
                if (let Some(actionEvt) <- evt as Event) {
                    if (actionEvt.id == id) {
                        return true
                    }
                }
            }
        }
        return false
    }

    public func remove(id: String): Unit {
        if (id.isEmpty() == false) {
            for (evt in m_events) {
                if (let Some(actionEvt) <- evt as Event) {
                    if (actionEvt.id == id) {
                        actionEvt.action = None
                    }
                }
            }
        }
    }

    public func removeAll(): Unit {
        for (evt in m_events) {
            if (let Some(actionEvt) <- evt as Event) {
                actionEvt.action = None
            }
        }
    }

    public func resetTime(id: String): Unit {
        if (id.isEmpty() == false) {
            for (evt in m_events) {
                if (let Some(actionEvt) <- evt as Event) {
                    if (actionEvt.id == id) {
                        actionEvt.resetTime()
                    }
                }
            }
        }
    }

    public func timeout(id: String): Unit {
        if (id.isEmpty() == false) {
            for (evt in m_events) {
                if (let Some(actionEvt) <- evt as Event) {
                    if (actionEvt.id == id) {
                        actionEvt.timeout()
                    }
                }
            }
        }
    }

    public func update(game: Game): Unit {
        m_events.removeIf({
            evt => evt(game) == true || (evt is Event) == false
        })
    }
}
