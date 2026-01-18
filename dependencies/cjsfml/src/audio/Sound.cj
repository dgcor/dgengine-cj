package cjsfml.audio

import cjsfml.system.*

foreign {
    func sfSound_create(buffer: CPointer<Unit>): CPointer<Unit>

    func sfSound_copy(handle: CPointer<Unit>): CPointer<Unit>

    func sfSound_destroy(handle: CPointer<Unit>): Unit

    // Sound

    func sfSound_setBuffer(handle: CPointer<Unit>, buffer: CPointer<Unit>): Unit

    func sfSound_getBuffer(handle: CPointer<Unit>): CPointer<Unit>

    func sfSound_setLooping(handle: CPointer<Unit>, loop: Bool): Unit

    func sfSound_isLooping(handle: CPointer<Unit>): Bool

    func sfSound_play(handle: CPointer<Unit>): Unit

    func sfSound_pause(handle: CPointer<Unit>): Unit

    func sfSound_stop(handle: CPointer<Unit>): Unit

    func sfSound_getStatus(handle: CPointer<Unit>): SoundStatus

    func sfSound_getPlayingOffset(handle: CPointer<Unit>): Time

    func sfSound_setPitch(handle: CPointer<Unit>, pitch: Float32): Unit

    func sfSound_setVolume(handle: CPointer<Unit>, volume: Float32): Unit

    func sfSound_setPosition(handle: CPointer<Unit>, position: Vector3f): Unit

    func sfSound_setRelativeToListener(handle: CPointer<Unit>, relative: Bool): Unit

    func sfSound_setMinDistance(handle: CPointer<Unit>, distance: Float32): Unit

    func sfSound_setAttenuation(handle: CPointer<Unit>, attenuation: Float32): Unit

    func sfSound_setPlayingOffset(handle: CPointer<Unit>, timeOffset: Time): Unit

    func sfSound_setEffectProcessor(handle: CPointer<Unit>, effectProcessor: EffectProcessor): Unit

    func sfSound_getPitch(handle: CPointer<Unit>): Float32

    func sfSound_getVolume(handle: CPointer<Unit>): Float32

    func sfSound_getPosition(handle: CPointer<Unit>): Vector3f

    func sfSound_isRelativeToListener(handle: CPointer<Unit>): Bool

    func sfSound_getMinDistance(handle: CPointer<Unit>): Float32

    func sfSound_getAttenuation(handle: CPointer<Unit>): Float32
}

public class Sound <: ResourceHandle & Equatable<Sound> {
    private var m_handle: CPointer<Unit> = CPointer()

    public init(buffer: SoundBuffer) {
        m_handle = unsafe { sfSound_create(buffer.handle) }
        if (m_handle.isNull()) {
            throw SFMLNullHandleException()
        }
    }

    private init(handle: CPointer<Unit>) {
        if (handle.isNull()) {
            throw SFMLNullHandleException()
        }
        m_handle = handle
    }

    ~init() {
        if (m_handle.isNotNull()) {
            unsafe { sfSound_destroy(m_handle) }
            m_handle = CPointer()
        }
    }

    public func clone() {
        Sound(unsafe { sfSound_copy(m_handle) })
    }

    // ResourceHandle

    public func isClosed(): Bool {
        m_handle.isNull()
    }

    public func close(): Unit {
        if (isClosed()) {
            return
        }
        unsafe { sfSound_destroy(m_handle) }
        m_handle = CPointer()
    }

    public prop handle: CPointer<Unit> {
        get() {
            m_handle
        }
    }

    // Equatable

    public operator override func ==(right: Sound): Bool {
        m_handle.toUIntNative() == right.m_handle.toUIntNative()
    }

    public operator override func !=(right: Sound): Bool {
        m_handle.toUIntNative() != right.m_handle.toUIntNative()
    }

    // Sound

    public mut prop buffer: ?SoundBuffer {
        get() {
            let bufferPtr = unsafe { sfSound_getBuffer(m_handle) }
            if (bufferPtr.isNull()) {
                return None
            }
            SoundBuffer(bufferPtr, isOwner: false)
        }
        set(value) {
            unsafe { sfSound_setBuffer(m_handle, value?.handle ?? CPointer()) }
        }
    }

    public mut prop loop: Bool {
        get() {
            unsafe { sfSound_isLooping(m_handle) }
        }
        set(value) {
            unsafe { sfSound_setLooping(m_handle, value) }
        }
    }

    public func play(): Unit {
        unsafe { sfSound_play(m_handle) }
    }

    public func pause(): Unit {
        unsafe { sfSound_pause(m_handle) }
    }

    public func stop(): Unit {
        unsafe { sfSound_stop(m_handle) }
    }

    public func setEffectProcessor(effectProcessor: ?EffectProcessor): Unit {
        match (effectProcessor) {
            case Some(effectProcessor) => unsafe { sfSound_setEffectProcessor(m_handle, effectProcessor) }
            case None => unsafe { sfSound_setEffectProcessor(m_handle, CPointer()) }
        }
    }

    public prop status: SoundStatus {
        get() {
            unsafe { sfSound_getStatus(m_handle) }
        }
    }

    public mut prop pitch: Float32 {
        get() {
            unsafe { sfSound_getPitch(m_handle) }
        }
        set(value) {
            unsafe { sfSound_setPitch(m_handle, value) }
        }
    }

    public mut prop volume: Float32 {
        get() {
            unsafe { sfSound_getVolume(m_handle) }
        }
        set(value) {
            unsafe { sfSound_setVolume(m_handle, value) }
        }
    }

    public mut prop position: Vector3f {
        get() {
            unsafe { sfSound_getPosition(m_handle) }
        }
        set(value) {
            unsafe { sfSound_setPosition(m_handle, value) }
        }
    }

    public mut prop relativeToListener: Bool {
        get() {
            unsafe { sfSound_isRelativeToListener(m_handle) }
        }
        set(value) {
            unsafe { sfSound_setRelativeToListener(m_handle, value) }
        }
    }

    public mut prop minDistance: Float32 {
        get() {
            unsafe { sfSound_getMinDistance(m_handle) }
        }
        set(value) {
            unsafe { sfSound_setMinDistance(m_handle, value) }
        }
    }

    public mut prop attenuation: Float32 {
        get() {
            unsafe { sfSound_getAttenuation(m_handle) }
        }
        set(value) {
            unsafe { sfSound_setAttenuation(m_handle, value) }
        }
    }

    public mut prop playingOffset: Time {
        get() {
            unsafe { sfSound_getPlayingOffset(m_handle) }
        }
        set(value) {
            unsafe { sfSound_setPlayingOffset(m_handle, value) }
        }
    }
}
