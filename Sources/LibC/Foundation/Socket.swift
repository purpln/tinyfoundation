extension in_addr {
    public init?(_ address: String) throws {
        var addr = in_addr()
        switch inet_pton(AF_INET, address, &addr) {
        case 1: self = addr
        case 0: return nil
        case -1: throw Errno()
        default: preconditionFailure("inet_pton: unexpected return code")
        }
    }
}

extension in6_addr {
    public init?(_ address: String) throws {
        var addr6 = in6_addr()
        switch inet_pton(AF_INET6, address, &addr6) {
        case 1: self = addr6
        case 0: return nil
        case -1: throw Errno()
        default: preconditionFailure("inet_pton: unexpected return code")
        }
    }
}

extension sockaddr_in {
    public init(_ storage: sockaddr_storage) {
        var storage = storage
        var sockaddr = sockaddr_in()
        memcpy(&sockaddr, &storage, Int(sockaddr_in.size))
        self = sockaddr
    }
}

extension sockaddr_in6 {
    public init(_ storage: sockaddr_storage) {
        var storage = storage
        var sockaddr = sockaddr_in6()
        memcpy(&sockaddr, &storage, Int(sockaddr_in6.size))
        self = sockaddr
    }
}

extension sockaddr_un {
    public init(_ storage: sockaddr_storage) {
        var storage = storage
        var sockaddr = sockaddr_un()
        memcpy(&sockaddr, &storage, Int(sockaddr_un.size))
        self = sockaddr
    }
}

extension sockaddr_storage {
    public static var size: socklen_t {
        socklen_t(MemoryLayout<sockaddr_storage>.size)
    }
}

extension sockaddr_in {
    public var address: String {
        sin_addr.description
    }
    
    public var port: UInt16 {
        get { sin_port.bigEndian }
        set { sin_port = in_port_t(newValue).bigEndian }
    }
    
    public var family: CInt {
        get { CInt(sin_family) }
        set { sin_family = sa_family_t(newValue) }
    }
    
    public static var size: socklen_t {
        socklen_t(MemoryLayout<sockaddr_in>.size)
    }
    
    public init(_ address: in_addr, _ port: UInt16) throws {
        var sockaddr = sockaddr_in()
#if canImport(Darwin.C)
        sockaddr.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
#endif
        sockaddr.family = AF_INET
        sockaddr.sin_addr = address
        sockaddr.port = port
        self = sockaddr
    }
    
    public init(_ address: String, _ port: Int) throws {
        guard let address = try in_addr(address),
              let port = UInt16(exactly: port)
        else {
            throw Errno.invalidArgument
        }
        try self.init(address, port)
    }
}

extension sockaddr_in6 {
    public var address: String {
        sin6_addr.description
    }
    
    public var port: UInt16 {
        get { sin6_port.bigEndian }
        set { sin6_port = in_port_t(newValue).bigEndian }
    }
    
    public var family: CInt {
        get { CInt(sin6_family) }
        set { sin6_family = sa_family_t(newValue) }
    }
    
    public static var size: socklen_t {
        socklen_t(MemoryLayout<sockaddr_in6>.size)
    }
    
    public init(_ address: in6_addr, _ port: UInt16) throws {
        var sockaddr = sockaddr_in6()
#if canImport(Darwin.C)
        sockaddr.sin6_len = UInt8(MemoryLayout<sockaddr_in6>.size)
#endif
        sockaddr.family = AF_INET6
        sockaddr.sin6_addr = address
        sockaddr.port = port
        self = sockaddr
    }
    
    public init(_ address: String, _ port: Int) throws {
        guard let address = try in6_addr(address),
              let port = UInt16(exactly: port)
        else {
            throw Errno.invalidArgument
        }
        try self.init(address, port)
    }
}

extension sockaddr_un {
    public var address: String {
        description
    }
    
    public var family: CInt {
        get { CInt(sun_family) }
        set { sun_family = sa_family_t(newValue) }
    }
    
    public static var size: socklen_t {
        socklen_t(MemoryLayout<sockaddr_un>.size)
    }
    
    public init(_ address: String) throws {
        guard address.starts(with: "/") else {
            throw Errno.invalidArgument
        }
        var bytes = [UInt8](address.utf8)
        var sockaddr = sockaddr_un()
        let size = MemoryLayout.size(ofValue: sockaddr.sun_path)
        guard bytes.count < size else {
            throw Errno.invalidArgument
        }
#if canImport(Darwin.C)
        sockaddr.sun_len = UInt8(sockaddr_un.size)
#endif
        sockaddr.family = AF_UNIX
        memcpy(&sockaddr.sun_path, &bytes, bytes.count)
        self = sockaddr
    }
}

extension in6_addr {
#if canImport(Darwin.C)
    public init(
        _ tuple: (
            UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16
        )
    ) {
        self = in6_addr(
            __u6_addr: in6_addr.__Unnamed_union___u6_addr(
                __u6_addr16: (tuple)
            )
        )
    }
#elseif canImport(Glibc)
    public init(
        _ tuple: (
            UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16
        )
    ) {
        self = in6_addr(
            __in6_u: in6_addr.__Unnamed_union___in6_u(
                __u6_addr16: (tuple)
            )
        )
    }
#elseif canImport(Musl)
    public init(
        _ tuple: (
            UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16
        )
    ) {
        self = in6_addr(
            __in6_union: in6_addr.__Unnamed_union___in6_union(
                __s6_addr16: (tuple)
            )
        )
    }
#elseif canImport(Android)
    public init(
        _ tuple: (
            UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16
        )
    ) {
        self = in6_addr(
            in6_u: in6_addr.__Unnamed_union_in6_u(
                u6_addr16: (tuple)
            )
        )
    }
#endif
}

extension sockaddr_in: @retroactive CustomStringConvertible {
    public var description: String {
        "\(address):\(port)"
    }
}

extension sockaddr_in6: @retroactive CustomStringConvertible {
    public var description: String {
        "[\(address)]:\(port)"
    }
}

extension sockaddr_un: @retroactive CustomStringConvertible {
    public var description: String {
        var path = sun_path
        let size = MemoryLayout.size(ofValue: path)
        var bytes = [CChar](repeating: 0, count: size)
        memcpy(&bytes, &path, size - 1)
        return String(cString: bytes)
    }
}

extension in_addr: @retroactive CustomStringConvertible {
    public var description: String {
        var bytes = [CChar](repeating: 0, count: Int(INET_ADDRSTRLEN) + 1)
        var addr = self
        guard
            inet_ntop(AF_INET, &addr, &bytes, socklen_t(INET_ADDRSTRLEN)) != nil
        else {
            return ""
        }
        return String(cString: bytes)
    }
}

extension in6_addr: @retroactive CustomStringConvertible {
    public var description: String {
        var bytes = [CChar](repeating: 0, count: Int(INET6_ADDRSTRLEN) + 1)
        var addr = self
        guard
            inet_ntop(AF_INET6, &addr, &bytes, socklen_t(INET6_ADDRSTRLEN))
                != nil
        else {
            return ""
        }
        return String(cString: bytes)
    }
}

extension sockaddr_in: @retroactive Equatable {}
extension sockaddr_in6: @retroactive Equatable {}
extension sockaddr_un: @retroactive Equatable {}
extension in_addr: @retroactive Equatable {}
extension in6_addr: @retroactive Equatable {}

public protocol NativeStructEquatable {}

extension sockaddr_in: NativeStructEquatable {}
extension sockaddr_in6: NativeStructEquatable {}
extension sockaddr_un: NativeStructEquatable {}
extension in_addr: NativeStructEquatable {}
extension in6_addr: NativeStructEquatable {}

extension NativeStructEquatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        withUnsafeBytes(of: lhs) { lhs in
            withUnsafeBytes(of: rhs) { rhs in
                lhs.elementsEqual(rhs)
            }
        }
    }
}
