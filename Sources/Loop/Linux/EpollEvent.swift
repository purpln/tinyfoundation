#if canImport(Glibc) || canImport(Musl) || canImport(Android)
import LibC

extension epoll_event: EventProtocol {
    var pointer: UnsafeMutablePointer<Handler>? {
        get {
            data.ptr.assumingMemoryBound(to: Handler.self)
        }
        set {
            let pointer = UnsafeMutablePointer<Handler>.allocate(capacity: 1)
            data.ptr = UnsafeMutableRawPointer(pointer)
        }
    }
}

struct Flag: OptionSet {
    public let rawValue: UInt32
    
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
#if canImport(Glibc)
    public static let read = Flag(rawValue: EPOLLIN.rawValue)
    public static let write = Flag(rawValue: EPOLLOUT.rawValue)
#elseif canImport(Musl) || canImport(Android)
    public static let read = Flag(rawValue: UInt32(EPOLLIN))
    public static let write = Flag(rawValue: UInt32(EPOLLOUT))
#endif
}

extension LoopOperation {
    var flag: Flag {
        switch self {
        case .read: return .read
        case .write: return .write
        }
    }
}
#endif
