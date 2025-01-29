public struct FileDescriptor: RawRepresentable, Sendable, Equatable, Hashable {
    public let rawValue: CInt

    public init(rawValue: CInt) {
        self.rawValue = rawValue
    }
}

public extension FileDescriptor {
    @inlinable
    static var input: FileDescriptor  { FileDescriptor(rawValue: STDIN_FILENO) }
    
    @inlinable
    static var output: FileDescriptor { FileDescriptor(rawValue: STDOUT_FILENO) }
    
    @inlinable
    static var error: FileDescriptor  { FileDescriptor(rawValue: STDERR_FILENO) }
}

public extension FileDescriptor {
    var flags: CInt {
        get { fcntl(rawValue, F_GETFD, 0) }
        nonmutating set { _ = fcntl(rawValue, F_SETFD, newValue) }
    }

    var status: CInt {
        get { fcntl(rawValue, F_GETFL, 0) }
        nonmutating set { _ = fcntl(rawValue, F_SETFL, newValue) }
    }
}
