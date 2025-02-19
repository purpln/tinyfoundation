import LibC

public struct Socket: Sendable {
    public let descriptor: FileDescriptor
    
    public init(family: SocketFamily, type: SocketType = .stream) throws(Errno) {
        let result = try valueOrErrno(retryOnInterrupt: false, {
            socket(family.rawValue, type.rawValue, 0)
        }).get()
        
        self.init(descriptor: FileDescriptor(rawValue: result))
    }
    
    internal init(descriptor: FileDescriptor) {
        self.descriptor = descriptor
#if canImport(Darwin.C)
        self.noSignalPipe = true
#endif
        self.reuseAddr = true
        self.isNonBlocking = true
    }
}

public extension Socket {
    var address: SocketAddress? {
        var storage = sockaddr_storage()
        var size = sockaddr_storage.size
        getsockname(descriptor.rawValue, rebounded(&storage), &size)
        return SocketAddress(storage)
    }
    
    var peer: SocketAddress? {
        var storage = sockaddr_storage()
        var size = sockaddr_storage.size
        getpeername(descriptor.rawValue, rebounded(&storage), &size)
        return SocketAddress(storage)
    }
}

public extension Socket {
    var isNonBlocking: Bool {
        get {
            descriptor.status & O_NONBLOCK != 0
        }
        nonmutating set {
            switch newValue {
            case true: descriptor.status |= O_NONBLOCK
            case false: descriptor.status &= ~O_NONBLOCK
            }
        }
    }
#if canImport(Darwin.C)
    var noSignalPipe: Bool {
        get { try! getOption(.noSignalPipe) }
        nonmutating set { try! setOption(.noSignalPipe, to: newValue) }
    }
#endif
    
    var reuseAddr: Bool {
        get { try! getOption(.reuseAddr) }
        nonmutating set { try! setOption(.reuseAddr, to: newValue) }
    }
    
    var reusePort: Bool {
        get { try! getOption(.reusePort) }
        nonmutating set { try! setOption(.reusePort, to: newValue) }
    }
    
    var broadcast: Bool {
        get { try! getOption(.broadcast) }
        nonmutating set { try! setOption(.broadcast, to: newValue) }
    }
}

private extension Socket {
    func getOption(_ option: SocketOption) throws(Errno) -> Bool {
        try getValue(for: option.rawValue)
    }
    
    func setOption(_ option: SocketOption, to value: Bool) throws(Errno) {
        try setValue(value, for: option.rawValue)
    }
    
    func setValue(_ value: Bool, for option: CInt) throws(Errno) {
        var value: CInt = value ? 1 : 0
        try setValue(&value, size: MemoryLayout<CInt>.size, for: option)
    }
    
    func getValue(for option: CInt) throws(Errno) -> Bool {
        var value: CInt = 0
        var valueSize = MemoryLayout<CInt>.size
        try getValue(&value, size: &valueSize, for: option)
        return value == 0 ? false : true
    }
    
    func setValue(_ pointer: UnsafeRawPointer, size: Int, for option: CInt) throws(Errno) {
        try nothingOrErrno(retryOnInterrupt: false, {
            setsockopt(descriptor.rawValue, SOL_SOCKET, option, pointer, socklen_t(size))
        }).get()
    }
    
    func getValue(_ pointer: UnsafeMutableRawPointer, size: inout Int, for option: CInt) throws(Errno) {
        var actualSize = socklen_t(size)
        try nothingOrErrno(retryOnInterrupt: false, {
            getsockopt(descriptor.rawValue, SOL_SOCKET, option, pointer, &actualSize)
        }).get()
        size = Int(actualSize)
    }
}

private extension FileDescriptor {
    var flags: CInt {
        get { fcntl(rawValue, F_GETFD, 0) }
        nonmutating set { _ = fcntl(rawValue, F_SETFD, newValue) }
    }

    var status: CInt {
        get { fcntl(rawValue, F_GETFL, 0) }
        nonmutating set { _ = fcntl(rawValue, F_SETFL, newValue) }
    }
}
