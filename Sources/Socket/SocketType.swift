import LibC

public enum SocketType: Sendable {
    case stream, datagram, sequenced, raw
}

extension SocketType {
    var rawValue: CInt {
#if canImport(Darwin.C) || canImport(Musl) || canImport(Android)
        switch self {
        case .stream: return SOCK_STREAM
        case .datagram: return SOCK_DGRAM
        case .sequenced: return SOCK_SEQPACKET
        case .raw: return SOCK_RAW
        }
#elseif canImport(Glibc)
        switch self {
        case .stream: return CInt(SOCK_STREAM.rawValue)
        case .datagram: return CInt(SOCK_DGRAM.rawValue)
        case .sequenced: return CInt(SOCK_SEQPACKET.rawValue)
        case .raw: return CInt(SOCK_RAW.rawValue)
        }
#endif
    }
}
