#if canImport(Glibc) || canImport(Musl) || canImport(Android)
import LibC

struct Epoll: PollerProtocol {
    private var descriptor: FileDescriptor
    private var events: [epoll_event]
    
    public init() throws {
        let descriptor = try valueOrErrno(retryOnInterrupt: false, {
            epoll_create1(CInt(EPOLL_CLOEXEC))
        }).map(FileDescriptor.init(rawValue:)).get()
        self.descriptor = descriptor
        self.events = [epoll_event](repeating: epoll_event(), count: 256)
    }
    
    public mutating func poll(timeout: Duration?) throws -> ArraySlice<epoll_event> {
        var count: CInt = -1
        var deadline: CInt = -1
        if let timeout = timeout {
            deadline = timeout.timeoutSinceNow
        }
        repeat {
            count = try valueOrErrno(retryOnInterrupt: true, {
                epoll_wait(descriptor.rawValue, &events, CInt(events.count), deadline)
            }).get()
        } while count < 0
        return events.prefix(upTo: Int(count))
    }
    
    public func invalidate() throws {
        try descriptor.close()
    }
}

extension Epoll {
    public mutating func add(handler: Handler) throws {
        var event = epoll_event(events: handler.type.flag.rawValue, data: epoll_data())
        event.handler = handler
        try nothingOrErrno(retryOnInterrupt: false, {
            epoll_ctl(descriptor.rawValue, EPOLL_CTL_ADD, handler.descriptor.rawValue, &event)
        }).get()
    }
    
    public mutating func remove(handler: Handler) throws {
        var event = epoll_event(events: handler.type.flag.rawValue, data: epoll_data())
        try nothingOrErrno(retryOnInterrupt: false, {
            epoll_ctl(descriptor.rawValue, EPOLL_CTL_DEL, handler.descriptor.rawValue, &event)
        }).get()
    }
}

#endif
