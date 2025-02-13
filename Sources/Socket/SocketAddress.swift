import LibC

public enum SocketAddress: Sendable {
    case ipv4(sockaddr_in)
    case ipv6(sockaddr_in6)
    case unix(sockaddr_un)
    case unspecified
}

public extension SocketAddress {
    var size: socklen_t {
        switch self {
        case .ipv4: return sockaddr_in.size
        case .ipv6: return sockaddr_in6.size
        case .unix: return sockaddr_un.size
        case .unspecified: return 0
        }
    }
}

public extension SocketAddress {
    init(_ address: String, port: Int? = nil) throws {
        if let port = port {
            guard port <= UInt16.max else {
                throw SocketError.invalidPort
            }

            if let ip4 = try? SocketAddress(ipv4: address, port: port) {
                self = ip4
                return
            }

            if let ip6 = try? SocketAddress(ipv6: address, port: port) {
                self = ip6
                return
            }
        }

        if let unix = try? SocketAddress(unix: address) {
            self = unix
            return
        }

        throw SocketError.invalidAddress
    }
    
    init(ipv4 address: String, port: Int) throws {
        self = .ipv4(try sockaddr_in(address, port))
    }

    init(ipv6 address: String, port: Int) throws {
        self = .ipv6(try sockaddr_in6(address, port))
    }

    init(unix address: String) throws {
        self = .unix(try sockaddr_un(address))
    }
}

extension SocketAddress {
    init(_ storage: sockaddr_storage) {
        guard let family = SocketAddressFamily(storage.ss_family) else {
            preconditionFailure("sockaddr_storage: unexpected family")
        }
        switch family {
        case .inet: self = .ipv4(sockaddr_in(storage))
        case .inet6: self = .ipv6(sockaddr_in6(storage))
        case .unix: self = .unix(sockaddr_un(storage))
        case .unspecified: self = .unspecified
        }
    }
}

public extension SocketAddress {
    var family: SocketAddressFamily {
        switch self {
        case .ipv4: return .inet
        case .ipv6: return .inet6
        case .unix: return .unix
        case .unspecified: return .unspecified
        }
    }
}

extension SocketAddress: Equatable {
    public static func == (lhs: SocketAddress, rhs: SocketAddress) -> Bool {
        switch (lhs, rhs) {
        case let (.ipv4(lhs), .ipv4(rhs)): return lhs == rhs
        case let (.ipv6(lhs), .ipv6(rhs)): return lhs == rhs
        case let (.unix(lhs), .unix(rhs)): return lhs == rhs
        default: return false
        }
    }
}

extension SocketAddress: CustomStringConvertible {
    public var description: String {
        switch self {
        case .ipv4(let address): return address.description
        case .ipv6(let address): return address.description
        case .unix(let address): return address.description
        case .unspecified: return "unspecified"
        }
    }
}

public extension SocketAddress {
    func unlink() throws {
        guard case .unix(let address) = self else { return }
        let path = address.description
        try nothingOrErrno(retryOnInterrupt: false, {
            system_unlink(path)
        }).get()
    }
}
