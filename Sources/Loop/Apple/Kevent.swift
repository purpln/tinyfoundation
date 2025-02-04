#if canImport(Darwin.C)
import LibC

extension kevent64_s: EventProtocol {
    var pointer: UnsafeMutablePointer<Handler>? {
        get {
            UnsafeMutableRawPointer(bitPattern: UInt(Int64(bitPattern: udata)))?.assumingMemoryBound(to: Handler.self)
        }
        set {
            udata = UInt64(bitPattern: Int64(Int(bitPattern: newValue)))
        }
    }
}

struct Flag: OptionSet {
    public let rawValue: UInt16
    
    static let add = Flag(rawValue: UInt16(EV_ADD))
    static let delete = Flag(rawValue: UInt16(EV_DELETE))
}

struct Filter: OptionSet {
    public let rawValue: Int16
    
    static let read = Filter(rawValue: Int16(EVFILT_READ))
    static let write = Filter(rawValue: Int16(EVFILT_WRITE))
}

extension LoopOperation {
    var filter: Filter {
        switch self {
        case .read: return .read
        case .write: return .write
        }
    }
}
#endif
