public struct LockedState<State> {
    private class Buffer: ManagedBuffer<State, Lock.Primitive> {
        deinit {
            withUnsafeMutablePointerToElements {
                Lock.deinitialize($0)
            }
        }
    }

    private let buffer: ManagedBuffer<State, Lock.Primitive>

    public init(_ initialState: State) {
        buffer = Buffer.create(minimumCapacity: 1, makingHeaderWith: { buf in
            buf.withUnsafeMutablePointerToElements {
                Lock.initialize($0)
            }
            return initialState
        })
    }

    public func withLock<T>(_ body: @Sendable (inout State) throws -> T) rethrows -> T {
        try withLockUnchecked(body)
    }

    public func withLockUnchecked<T>(_ body: (inout State) throws -> T) rethrows -> T {
        try buffer.withUnsafeMutablePointers { state, lock in
            Lock.lock(lock)
            defer { Lock.unlock(lock) }
            return try body(&state.pointee)
        }
    }

    // Ensures the managed state outlives the locked scope.
    public func withLockExtendingLifetimeOfState<T>(_ body: @Sendable (inout State) throws -> T) rethrows -> T {
        try buffer.withUnsafeMutablePointers { state, lock in
            Lock.lock(lock)
            return try withExtendedLifetime(state.pointee) {
                defer { Lock.unlock(lock) }
                return try body(&state.pointee)
            }
        }
    }
}

extension LockedState where State == Void {
    public init() {
        self.init(())
    }

    public func withLock<R: Sendable>(_ body: @Sendable () throws -> R) rethrows -> R {
        return try withLock { _ in
            try body()
        }
    }

    public func lock() {
        buffer.withUnsafeMutablePointerToElements { lock in
            Lock.lock(lock)
        }
    }

    public func unlock() {
        buffer.withUnsafeMutablePointerToElements { lock in
            Lock.unlock(lock)
        }
    }
}

extension LockedState: @unchecked Sendable where State: Sendable {}
