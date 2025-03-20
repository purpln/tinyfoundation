#if canImport(Darwin.C)
import LibC

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
struct Kqueue: PollerProtocol {
    private var descriptor: FileDescriptor
    private var events: [kevent64_s] = []
    
    public init() throws {
        let descriptor = try valueOrErrno(retryOnInterrupt: false, {
            kqueue()
        }).map(FileDescriptor.init(rawValue:)).get()
        descriptor.flags |= FD_CLOEXEC
        self.descriptor = descriptor
    }
    
    public mutating func poll(timeout: Duration?) throws -> ArraySlice<kevent64_s> {
        var result = [kevent64_s()]
        
        let count: CInt
        if let timeout = timeout {
            let deadline = timeout.timeoutSinceNow
            count = try valueOrErrno(retryOnInterrupt: true, {
                withUnsafePointer(to: deadline, { pointer in
                    kevent64(descriptor.rawValue, events, CInt(events.count), &result, CInt(result.count), 0, pointer)
                })
            }).get()
        } else {
            count = try valueOrErrno(retryOnInterrupt: true, {
                kevent64(descriptor.rawValue, events, CInt(events.count), &result, CInt(result.count), 0, nil)
            }).get()
        }
        events = []
        return result.prefix(upTo: Int(count))
    }
    
    public func invalidate() throws {
        try descriptor.close()
    }
}

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
extension Kqueue {
    private func event(with handler: Handler) -> kevent64_s {
        let identifier = UInt64(handler.descriptor.rawValue)
        let filter: Int16 = handler.type.filter.rawValue
        let flags: UInt16 = 0
        let fflags: UInt32 = 0
        let data: Int64 = 0
        let ext: (UInt64, UInt64) = (0, 0)
        
        return kevent64_s(ident: identifier, filter: filter, flags: flags, fflags: fflags, data: data, udata: 0, ext: ext)
    }
    
    public mutating func add(handler: Handler) throws {
        var event = event(with: handler)
        event.handler = handler
        event.flags = Flag.add.rawValue
        events.append(event)
    }
    
    public mutating func remove(handler: Handler) throws {
        var event = event(with: handler)
        event.flags = Flag.delete.rawValue
        events.append(event)
    }
}

private extension FileDescriptor {
    var flags: CInt {
        get { fcntl(rawValue, F_GETFD, 0) }
        nonmutating set { _ = fcntl(rawValue, F_SETFD, newValue) }
    }
}
#endif
