import LibC

public enum Handler: Equatable {
    case `default`
    case ignore
    case posix(@convention(c) (CInt, UnsafeMutablePointer<siginfo_t>?, UnsafeMutableRawPointer?) -> Void)
    case ansiC(@convention(c) (CInt) -> Void)
    
    var pointer: OpaquePointer? {
        switch self {
        case .default: return OpaquePointer(bitPattern: unsafeBitCast(SIG_DFL, to: Int.self))
        case .ignore: return OpaquePointer(bitPattern: unsafeBitCast(SIG_IGN, to: Int.self))
        case .posix(let handler): return OpaquePointer(bitPattern: unsafeBitCast(handler, to: Int.self))
        case .ansiC(let handler): return OpaquePointer(bitPattern: unsafeBitCast(handler, to: Int.self))
        }
    }
}

public extension Handler {
    static func ==(lhs: Handler, rhs: Handler) -> Bool {
        switch (lhs, rhs) {
        case (.default, .default), (.ignore, .ignore):
            return true
        case (.posix, .posix), (.ansiC, .ansiC):
            return lhs.pointer == rhs.pointer
        case (.default, _), (.ignore, _), (.posix, _), (.ansiC, _):
            return false
        }
    }
}
