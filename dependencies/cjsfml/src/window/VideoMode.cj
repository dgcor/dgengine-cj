package cjsfml.window

import cjsfml.system.*

foreign {
    func sfVideoMode_getDesktopMode(): VideoMode

    func sfVideoMode_getFullscreenModes(count: CPointer<UIntNative>): CPointer<VideoMode>

    func sfVideoMode_isValid(mode: VideoMode): Bool
}

@C
public struct VideoMode {
    public let size: Vector2u
    public let bitsPerPixel: UInt32

    public const init() {
        size = Vector2u()
        bitsPerPixel = 0
    }

    public const init(size: Vector2u, bitsPerPixel!: UInt32 = 32) {
        this.size = size
        this.bitsPerPixel = bitsPerPixel
    }

    public static prop desktopMode: VideoMode {
        get() {
            unsafe { sfVideoMode_getDesktopMode() }
        }
    }

    public static prop fullscreenModes: Array<VideoMode> {
        get() {
            unsafe {
                var count: UIntNative = 0
                var modesPtr = sfVideoMode_getFullscreenModes(inout count)
                var modes = Array<VideoMode>(Int64(count), repeat: VideoMode())
                for (i in 0..Int64(count)) {
                    modes[i] = modesPtr.read(i)
                }
                return modes
            }
        }
    }

    public static func isValid(mode: VideoMode): Bool {
        unsafe { sfVideoMode_isValid(mode) }
    }
}
