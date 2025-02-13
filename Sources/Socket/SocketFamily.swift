import LibC

public enum SocketFamily: Sendable {
    case unix, ipv4, ipv6
}

extension SocketFamily {
    var rawValue: CInt {
        switch self {
        case .unix: return PF_LOCAL
        case .ipv4: return PF_INET
        case .ipv6: return PF_INET6
        }
    }
}
