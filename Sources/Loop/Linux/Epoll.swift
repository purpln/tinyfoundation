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
            deadline = ContinuousClock.Instant.now.advanced(by: timeout).timeoutSinceNow
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
    private func event(with handler: Handler, operation: Operation) -> epoll_event {
        let events: Flag
        switch handler.type {
        case .read:
            events = .read
        case .write:
            events = .write
        }
        return epoll_event(events: events.rawValue, data: epoll_data())
    }
    
    public mutating func add(handler: Handler) throws {
        var event = event(with: handler, operation: .add)
        event.handler = handler
        try nothingOrErrno(retryOnInterrupt: false, {
            epoll_ctl(descriptor.rawValue, EPOLL_CTL_ADD, handler.descriptor.rawValue, &event)
        }).get()
    }
    
    public mutating func remove(handler: Handler) throws {
        var event = event(with: handler, operation: .remove)
        try nothingOrErrno(retryOnInterrupt: false, {
            epoll_ctl(descriptor.rawValue, EPOLL_CTL_DEL, handler.descriptor.rawValue, &event)
        }).get()
    }
}

#endif
