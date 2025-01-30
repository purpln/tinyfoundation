#if canImport(Darwin.C)
import LibC

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
        
        var count: CInt
        if let timeout = timeout {
            var deadline = ContinuousClock.now.advanced(by: timeout).timeoutSinceNow
            count = try valueOrErrno(retryOnInterrupt: true, {
                kevent64(descriptor.rawValue, events, CInt(events.count), &result, CInt(result.count), 0, &deadline)
            }).get()
        } else {
            count = try valueOrErrno(retryOnInterrupt: true, {
                kevent64(descriptor.rawValue, events, CInt(events.count), &result, CInt(result.count), 0, nil)
            }).get()
        }
        events = []
        /*
        guard count >= 0 else {
            let errno = Errno()
            if errno == .interrupted {
                return []
            }
            throw errno
        }
        */
        return result.prefix(upTo: Int(count))
    }
    
    public func invalidate() throws {
        try descriptor.close()
    }
}

extension Kqueue {
    private func event(with handler: Handler, operation: Operation) -> kevent64_s {
        let identifier = UInt64(handler.descriptor.rawValue)
        let filter: Int16 = handler.type.filter.rawValue
        let flags: UInt16
        let fflags: UInt32 = 0
        let data: Int64 = 0
        let ext: (UInt64, UInt64) = (0, 0)
        
        switch operation {
        case .add: flags = Flag.add.rawValue
        case .remove: flags = Flag.delete.rawValue
        }
        return kevent64_s(ident: identifier, filter: filter, flags: flags, fflags: fflags, data: data, udata: 0, ext: ext)
    }
    
    public mutating func add(handler: Handler) throws {
        var event = event(with: handler, operation: .add)
        event.handler = handler
        events.append(event)
    }
    
    public mutating func remove(handler: Handler) throws {
        let event = event(with: handler, operation: .remove)
        events.append(event)
    }
}
#endif
