import LibC

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
protocol LoopProtocol {
    associatedtype Poller: PollerProtocol
    static func respondent() throws -> Poller
    
    func once(timeout: Duration?) async throws
    func run(timeout: Duration?) async throws
    func wait(for descriptor: FileDescriptor, type: LoopOperation, deadline: ContinuousClock.Instant?) async throws
    func invalidate() async throws
}

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
protocol PollerProtocol {
    associatedtype Event: EventProtocol
    
    init() throws
    
    mutating func poll(timeout: Duration?) throws -> ArraySlice<Event>
    func invalidate() throws
    
    mutating func add(handler: Handler) throws
    mutating func remove(handler: Handler) throws
}

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
protocol EventProtocol {
    var handler: Handler? { get set }
    var pointer: UnsafeMutablePointer<Handler>? { get set }
    
    func invalidate()
}

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
extension EventProtocol {
    var handler: Handler? {
        get {
            pointer?.pointee
        }
        set {
            guard let value = newValue else { return }
            pointer = UnsafeMutablePointer<Handler>.allocate(capacity: 1)
            pointer?.initialize(to: value)
        }
    }
    
    func invalidate() {
        pointer?.deinitialize(count: 1)
        pointer?.deallocate()
    }
}

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
struct Handler {
    let descriptor: FileDescriptor
    let type: LoopOperation
    let continuation: UnsafeContinuation<Void, Error>?
}
