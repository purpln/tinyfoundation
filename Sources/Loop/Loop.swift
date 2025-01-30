import LibC

// - Linux/Android: epoll
// - MacOS/BSD: kqueue
// - (Windows: select)
// - (other POSIX: poll)

public actor Loop: LoopProtocol {
    private var poller: Poller
    public var running: Bool = false
    
    public init() throws {
        errno = 0
        
        setbuf(stdout, nil)
        setbuf(stderr, nil)
        
        poller = try Loop.respondent()
    }
    
    deinit {
        try? poller.invalidate()
    }
    
    public func run(timeout: Duration? = .milliseconds(10)) async throws {
        running = true
        repeat {
            try await once(timeout: timeout)
        } while running
    }
    
    public func once(timeout: Duration? = .milliseconds(10)) async throws {
        try poll(timeout: timeout)
        await Task.yield()
    }
    
    public func wait(for descriptor: FileDescriptor, type: IO, deadline: ContinuousClock.Instant? = nil) async throws {
        try await withUnsafeThrowingContinuation { continuation in
            do {
                try insertContinuation(continuation, for: descriptor, type: type)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    public func invalidate() async throws {
        try poller.invalidate()
        running = false
        exit(0)
    }
}

private extension Loop {
    func poll(timeout: Duration?) throws {
        let events = try poller.poll(timeout: timeout)
        try schedule(events: events)
    }
    
    func schedule(events: ArraySlice<Poller.Event>) throws {
        for event in events {
            defer {
                event.invalidate()
            }
            
            guard let handler = event.handler else { continue }
            try removeContinuation(for: handler)
            
            guard let contunation = handler.continuation else { continue }
            contunation.resume(returning: ())
        }
    }
}

private extension Loop {
    func insertContinuation(_ handler: UnsafeContinuation<Void, Error>, for descriptor: FileDescriptor, type: IO) throws {
        let handler = Handler(descriptor: descriptor, type: type, continuation: handler)
        try poller.add(handler: handler)
    }
    
    func removeContinuation(for handler: Handler) throws {
        try poller.remove(handler: handler)
    }
}

public extension Loop {
    static let main = try! Loop()
}

extension Loop {
#if canImport(Darwin.C)
    static func respondent() throws -> Kqueue {
        try Kqueue()
    }
#elseif canImport(Glibc) || canImport(Musl) || canImport(Android)
    static func respondent() throws -> Epoll {
        try Epoll()
    }
#endif
}
