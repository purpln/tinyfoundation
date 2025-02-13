import LibC

func rebounded<T>(_ pointer: UnsafePointer<T>) -> UnsafePointer<sockaddr> {
    UnsafeRawPointer(pointer).assumingMemoryBound(to: sockaddr.self)
}

func rebounded<T>(_ pointer: UnsafeMutablePointer<T>) -> UnsafeMutablePointer<sockaddr> {
    UnsafeMutableRawPointer(pointer).assumingMemoryBound(to: sockaddr.self)
}

public extension Socket {
    func bind(to address: SocketAddress) throws(Errno) {
        var copy = address
        try nothingOrErrno(retryOnInterrupt: false, {
            system_bind(descriptor.rawValue, rebounded(&copy), address.size)
        }).get()
    }
    
    func listen(backlog: Int = 256) throws(Errno) {
        try nothingOrErrno(retryOnInterrupt: false, {
            system_listen(descriptor.rawValue, CInt(backlog))
        }).get()
    }
    
    func accept() throws(Errno) -> Socket {
        let result = try valueOrErrno(retryOnInterrupt: false, {
            system_accept(descriptor.rawValue, nil, nil)
        }).map(FileDescriptor.init(rawValue:)).get()
        return Socket(descriptor: result)
    }
    
    func connect(to address: SocketAddress) throws(Errno) {
        var copy = address
        try nothingOrErrno(retryOnInterrupt: false, {
            system_connect(descriptor.rawValue, rebounded(&copy), copy.size)
        }).get()
    }
    
    func close() throws {
        try descriptor.close()
    }

    func send(bytes buffer: UnsafeRawPointer, count: Int) throws(Errno) -> Int {
        try valueOrErrno(retryOnInterrupt: false, {
            system_send(descriptor.rawValue, buffer, count, 0)
        }).get()
    }

    func receive(to buffer: UnsafeMutableRawPointer, count: Int) throws(Errno) -> Int {
        try valueOrErrno(retryOnInterrupt: false, {
            system_recv(descriptor.rawValue, buffer, count, 0)
        }).get()
    }

    func send(bytes buffer: UnsafeRawPointer, count: Int, to address: SocketAddress) throws(Errno) -> Int {
        var copy = address
        return try valueOrErrno(retryOnInterrupt: false, {
            system_sendto(descriptor.rawValue, buffer, count, 0, rebounded(&copy), copy.size)
        }).get()
    }

    func receive(to buffer: UnsafeMutableRawPointer, count: Int) throws(Errno) -> (count: Int, from: SocketAddress) {
        var storage = sockaddr_storage()
        var size = sockaddr_storage.size
        let received = try valueOrErrno(retryOnInterrupt: false, {
            system_recvfrom(descriptor.rawValue, buffer, count, 0, rebounded(&storage), &size)
        }).get()
        let address = SocketAddress(storage)
        return (received, address)
    }
}
