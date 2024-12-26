#if canImport(Glibc) || canImport(Musl) || canImport(Android)
import LibC

struct Epoll: PollerProtocol {
    private var descriptor: FileDescriptor
    private var events: [epoll_event]
    
    public init() throws {
        let ret = epoll_create1(CInt(EPOLL_CLOEXEC))
        
        self.descriptor = try FileDescriptor(with: ret)
        self.events = [epoll_event](repeating: epoll_event(), count: 256)
    }
    
    public mutating func poll(timeout: Duration?) throws -> ArraySlice<epoll_event> {
        var count: CInt = -1
        var deadline: CInt = -1
        if let timeout = timeout {
            deadline = ContinuousClock.Instant.now.advanced(by: timeout).timeoutSinceNow
        }
        repeat {
            count = epoll_wait(descriptor.rawValue, &events, CInt(events.count), deadline)
            guard count == -1 else { continue }
            throw Errno()
        } while count < 0
        return events.prefix(upTo: Int(count))
    }
    
    public func invalidate() throws {
        guard close(descriptor.rawValue) != 0 else { return }
        throw Errno()
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
        let result = epoll_ctl(descriptor.rawValue, EPOLL_CTL_ADD, handler.descriptor.rawValue, &event)
        guard result == 0 else {
            throw Errno()
        }
    }
    
    public mutating func remove(handler: Handler) throws {
        var event = event(with: handler, operation: .remove)
        let result = epoll_ctl(descriptor.rawValue, EPOLL_CTL_DEL, handler.descriptor.rawValue, &event)
        guard result == 0 else {
            throw Errno()
        }
    }
}

#endif
