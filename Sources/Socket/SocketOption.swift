import LibC

public enum SocketOption: Sendable {
    case reuseAddr, reusePort, broadcast
#if canImport(Darwin.C)
    case noSignalPipe
#endif
}

extension SocketOption {
    var rawValue: CInt {
        switch self {
        case .reuseAddr: return SO_REUSEADDR
        case .reusePort: return SO_REUSEPORT
        case .broadcast: return SO_BROADCAST
#if canImport(Darwin.C)
        case .noSignalPipe: return SO_NOSIGPIPE
#endif
        }
    }
}

