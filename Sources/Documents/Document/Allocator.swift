import LibC

class Allocator<Pointer> {
    public var allocated: Bool = false
    private var open: () -> Pointer?
    private var close: (Pointer) -> Void
    
    public init(open: @escaping () -> Pointer?, close: @escaping (Pointer) -> Void) {
        self.open = open
        self.close = close
    }
    
    deinit {
        guard allocated, let pointer = value else { return }
        close(pointer)
    }
    
    private lazy var value: Pointer? = {
        defer { allocated = true }
        return open()
    }()
    
    public func pointer() throws -> Pointer {
        guard let pointer = value else { throw Errno() }
        return pointer
    }
}
