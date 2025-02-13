@preconcurrency import LibC

// - Linux/Android: epoll
// - MacOS/BSD: kqueue
// - (Windows: select)
// - (other POSIX: poll)

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
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
    
    public func wait(for descriptor: FileDescriptor, type: LoopOperation, deadline: ContinuousClock.Instant? = nil) async throws {
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

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
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

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
private extension Loop {
    func insertContinuation(_ handler: UnsafeContinuation<Void, Error>, for descriptor: FileDescriptor, type: LoopOperation) throws {
        let handler = Handler(descriptor: descriptor, type: type, continuation: handler)
        try poller.add(handler: handler)
    }
    
    func removeContinuation(for handler: Handler) throws {
        try poller.remove(handler: handler)
    }
}

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
public extension Loop {
    static let main = try! Loop()
}

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
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

public enum LoopOperation: Sendable, Hashable {
    case read
    case write
}
