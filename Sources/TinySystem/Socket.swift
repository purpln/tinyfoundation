#if compiler(>=6.0)
public import LibC
#else
import LibC
#endif

#if os(Windows)
private typealias Family = UInt16
private typealias Port = UInt16
#else
private typealias Family = sa_family_t
private typealias Port = in_port_t
#endif

public extension in_addr {
    init?(_ address: String) {
        var addr = in_addr()
        let result = inet_pton(AF_INET, address, &addr)
        
        switch result {
        case 1: self = addr
        case 0, -1: return nil
        default: preconditionFailure("inet_pton: unexpected return code")
        }
    }
}

public extension in6_addr {
    init?(_ address: String) {
        var addr = in6_addr()
        let result = inet_pton(AF_INET6, address, &addr)
        
        switch result {
        case 1: self = addr
        case 0, -1: return nil
        default: preconditionFailure("inet_pton: unexpected return code")
        }
    }
}

public extension sockaddr_in {
    init(_ storage: sockaddr_storage) {
        var sockaddr = sockaddr_in()
        _ = withUnsafePointer(to: storage, {
            memcpy(&sockaddr, $0, Int(sockaddr_in.size))
        })
        self = sockaddr
    }
}

public extension sockaddr_in6 {
    init(_ storage: sockaddr_storage) {
        var sockaddr = sockaddr_in6()
        _ = withUnsafePointer(to: storage, {
            memcpy(&sockaddr, $0, Int(sockaddr_in6.size))
        })
        self = sockaddr
    }
}

public extension sockaddr_un {
    init(_ storage: sockaddr_storage) {
        var sockaddr = sockaddr_un()
        _ = withUnsafePointer(to: storage, {
            memcpy(&sockaddr, $0, Int(sockaddr_un.size))
        })
        self = sockaddr
    }
}

public extension sockaddr_storage {
    static var size: socklen_t {
        socklen_t(MemoryLayout<sockaddr_storage>.size)
    }
}

public extension sockaddr_in {
    var address: String {
        sin_addr.description
    }
    
    var port: UInt16 {
        get { sin_port.bigEndian }
        set { sin_port = Port(newValue).bigEndian }
    }
    
    var family: CInt {
        get { CInt(sin_family) }
        set { sin_family = Family(newValue) }
    }
    
    static var size: socklen_t {
        socklen_t(MemoryLayout<sockaddr_in>.size)
    }
    
    init(_ address: in_addr, _ port: UInt16) {
        var sockaddr = sockaddr_in()
#if canImport(Darwin)
        sockaddr.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
#endif
        sockaddr.family = AF_INET
        sockaddr.sin_addr = address
        sockaddr.port = port
        self = sockaddr
    }
    
    init?(_ address: String, _ port: Int) {
        guard let address = in_addr(address),
              let port = UInt16(exactly: port)
        else {
            return nil
        }
        self.init(address, port)
    }
}

public extension sockaddr_in6 {
    var address: String {
        sin6_addr.description
    }
    
    var port: UInt16 {
        get { sin6_port.bigEndian }
        set { sin6_port = Port(newValue).bigEndian }
    }
    
    var family: CInt {
        get { CInt(sin6_family) }
        set { sin6_family = Family(newValue) }
    }
    
    static var size: socklen_t {
        socklen_t(MemoryLayout<sockaddr_in6>.size)
    }
    
    init(_ address: in6_addr, _ port: UInt16) {
        var sockaddr = sockaddr_in6()
#if canImport(Darwin)
        sockaddr.sin6_len = UInt8(MemoryLayout<sockaddr_in6>.size)
#endif
        sockaddr.family = AF_INET6
        sockaddr.sin6_addr = address
        sockaddr.port = port
        self = sockaddr
    }
    
    init?(_ address: String, _ port: Int) {
        guard let address = in6_addr(address),
              let port = UInt16(exactly: port)
        else {
            return nil
        }
        self.init(address, port)
    }
}

public extension sockaddr_un {
    var address: String {
        description
    }
    
    var family: CInt {
        get { CInt(sun_family) }
        set { sun_family = Family(newValue) }
    }
    
    static var size: socklen_t {
        socklen_t(MemoryLayout<sockaddr_un>.size)
    }
    
    init?(_ address: String) {
        guard address.starts(with: "/") else {
            return nil
        }
        var sockaddr = sockaddr_un()
#if os(WASI)
        return nil
#else
        let bytes = Array(address.utf8)
        let capacity = MemoryLayout.size(ofValue: sockaddr.sun_path)
        guard !bytes.contains(0), bytes.count < capacity else {
            return nil
        }
        withUnsafeMutableBytes(of: &sockaddr.sun_path, { destination in
            bytes.withUnsafeBytes({ source in
                destination.copyBytes(from: source)
            })
        })
#endif
#if canImport(Darwin)
        sockaddr.sun_len = UInt8(sockaddr_un.size)
#endif
        sockaddr.family = AF_UNIX
        self = sockaddr
    }
}

public extension in_addr {
    init(_ tuple: (UInt8, UInt8, UInt8, UInt8)) {
        let value = (UInt32(tuple.0) << 24)
        | (UInt32(tuple.1) << 16)
        | (UInt32(tuple.2) << 8)
        | UInt32(tuple.3)
#if os(Windows)
        self.init(S_un: in_addr.__Unnamed_union_S_un(S_addr: value.bigEndian))
#else
        self.init(s_addr: value.bigEndian)
#endif
    }
}

public extension in6_addr {
    init(
        _ tuple: (
            UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16
        )
    ) {
#if canImport(Darwin)
        self.init(
            __u6_addr: in6_addr.__Unnamed_union___u6_addr(
                __u6_addr16: tuple
            )
        )
#elseif canImport(Glibc)
        self.init(
            __in6_u: in6_addr.__Unnamed_union___in6_u(
                __u6_addr16: tuple
            )
        )
#elseif canImport(Musl)
        self.init(
            __in6_union: in6_addr.__Unnamed_union___in6_union(
                __s6_addr16: tuple
            )
        )
#elseif canImport(Android)
        self.init(
            in6_u: in6_addr.__Unnamed_union_in6_u(
                u6_addr16: tuple
            )
        )
#elseif os(Windows)
        self.init(u: in6_addr.__Unnamed_union_u(Word: tuple))
#endif
    }
}

#if compiler(>=5.8)
#if hasFeature(RetroactiveAttribute)
extension sockaddr_in: @retroactive CustomStringConvertible {}
extension sockaddr_in6: @retroactive CustomStringConvertible {}
extension sockaddr_un: @retroactive CustomStringConvertible {}
extension in_addr: @retroactive CustomStringConvertible {}
extension in6_addr: @retroactive CustomStringConvertible {}
#else
extension sockaddr_in: CustomStringConvertible {}
extension sockaddr_in6: CustomStringConvertible {}
extension sockaddr_un: CustomStringConvertible {}
extension in_addr: CustomStringConvertible {}
extension in6_addr: CustomStringConvertible {}
#endif
#else
extension sockaddr_in: CustomStringConvertible {}
extension sockaddr_in6: CustomStringConvertible {}
extension sockaddr_un: CustomStringConvertible {}
extension in_addr: CustomStringConvertible {}
extension in6_addr: CustomStringConvertible {}
#endif

extension sockaddr_in {
    public var description: String {
        "\(address):\(port)"
    }
}

extension sockaddr_in6 {
    public var description: String {
        "[\(address)]:\(port)"
    }
}

extension sockaddr_un {
    public var description: String {
#if !os(WASI)
        let size = MemoryLayout.size(ofValue: sun_path)
        return withUnsafePointer(to: sun_path, { pointer in
            pointer.withMemoryRebound(to: UInt8.self, capacity: size, { bytes in
                String(
                    decoding: UnsafeBufferPointer(start: bytes, count: size)
                        .prefix(while: { $0 != 0 }),
                    as: UTF8.self
                )
            })
        })
#else
        return ""
#endif
    }
}

extension in_addr {
    public var description: String {
        var bytes = [UInt8](repeating: 0, count: Int(INET_ADDRSTRLEN))
        let capacity = bytes.count
        let result = bytes.withUnsafeMutableBufferPointer({ buffer in
            buffer.baseAddress!.withMemoryRebound(to: CChar.self, capacity: capacity, { output in
                withUnsafePointer(to: self, {
                    inet_ntop(AF_INET, $0, output, socklen_t(capacity))
                })
            })
        })
        guard result != nil else { return "" }
        return String(decoding: bytes.prefix(while: { $0 != 0 }), as: UTF8.self)
    }
}

extension in6_addr {
    public var description: String {
        var bytes = [UInt8](repeating: 0, count: Int(INET6_ADDRSTRLEN))
        let capacity = bytes.count
        let result = bytes.withUnsafeMutableBufferPointer({ buffer in
            buffer.baseAddress!.withMemoryRebound(to: CChar.self, capacity: capacity, { output in
                withUnsafePointer(to: self, {
                    inet_ntop(AF_INET6, $0, output, socklen_t(capacity))
                })
            })
        })
        guard result != nil else { return "" }
        return String(decoding: bytes.prefix(while: { $0 != 0 }), as: UTF8.self)
    }
}

#if compiler(>=5.8)
#if hasFeature(RetroactiveAttribute)
extension sockaddr_in: @retroactive Equatable {}
extension sockaddr_in6: @retroactive Equatable {}
extension sockaddr_un: @retroactive Equatable {}
extension in_addr: @retroactive Equatable {}
extension in6_addr: @retroactive Equatable {}
#else
extension sockaddr_in: Equatable {}
extension sockaddr_in6: Equatable {}
extension sockaddr_un: Equatable {}
extension in_addr: Equatable {}
extension in6_addr: Equatable {}
#endif
#else
extension sockaddr_in: Equatable {}
extension sockaddr_in6: Equatable {}
extension sockaddr_un: Equatable {}
extension in_addr: Equatable {}
extension in6_addr: Equatable {}
#endif

public protocol NativeStructEquatable {}

extension sockaddr_in: NativeStructEquatable {}
extension sockaddr_in6: NativeStructEquatable {}
extension sockaddr_un: NativeStructEquatable {}
extension in_addr: NativeStructEquatable {}
extension in6_addr: NativeStructEquatable {}

extension NativeStructEquatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        withUnsafeBytes(of: lhs, { lhs in
            withUnsafeBytes(of: rhs, { rhs in
                lhs.elementsEqual(rhs)
            })
        })
    }
}
