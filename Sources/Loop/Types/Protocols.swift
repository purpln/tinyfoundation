import LibC

protocol LoopProtocol {
    associatedtype Poller: PollerProtocol
    static func respondent() throws -> Poller
    
    func once(timeout: Duration?) async throws
    func run(timeout: Duration?) async throws
    func wait(for descriptor: FileDescriptor, type: Loop.IO, deadline: ContinuousClock.Instant?) async throws
    func invalidate() async throws
}

protocol PollerProtocol {
    associatedtype Event: EventProtocol
    
    init() throws
    
    mutating func poll(timeout: Duration?) throws -> ArraySlice<Event>
    func invalidate() throws
    
    mutating func add(handler: Handler) throws
    mutating func remove(handler: Handler) throws
}

protocol EventProtocol {
    var handler: Handler? { get set }
    var pointer: UnsafeMutablePointer<Handler>? { get set }
    
    func invalidate()
}

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

enum Operation {
    case add
    case remove
}

struct Handler {
    let descriptor: FileDescriptor
    let type: Loop.IO
    let continuation: UnsafeContinuation<Void, Error>?
}
