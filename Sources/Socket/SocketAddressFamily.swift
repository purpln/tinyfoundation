import LibC

public enum SocketAddressFamily: Sendable {
    case inet, inet6, unspecified, unix
}

extension SocketAddressFamily: RawRepresentable {
    init?(_ family: sa_family_t) {
        self.init(rawValue: CInt(family))
    }

    public init?(rawValue: CInt) {
        switch rawValue {
        case AF_INET: self = .inet
        case AF_INET6: self = .inet6
        case AF_UNIX: self = .unix
        case AF_UNSPEC: self = .unspecified
        default: return nil
        }
    }

    public var rawValue: CInt {
        switch self {
        case .inet: return AF_INET
        case .inet6: return AF_INET6
        case .unix: return AF_UNIX
        case .unspecified: return AF_UNSPEC
        }
    }
}
