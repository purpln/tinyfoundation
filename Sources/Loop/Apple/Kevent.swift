#if canImport(Darwin.C)
import LibC

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
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

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
struct Flag: OptionSet {
    public let rawValue: UInt16
    
    static let add = Flag(rawValue: UInt16(EV_ADD))
    static let delete = Flag(rawValue: UInt16(EV_DELETE))
}

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
struct Filter: OptionSet {
    public let rawValue: Int16
    
    static let read = Filter(rawValue: Int16(EVFILT_READ))
    static let write = Filter(rawValue: Int16(EVFILT_WRITE))
}

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
extension LoopOperation {
    var filter: Filter {
        switch self {
        case .read: return .read
        case .write: return .write
        }
    }
}
#endif
