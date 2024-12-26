public struct FileDescriptor: RawRepresentable, Sendable, Equatable, Hashable {
    public let rawValue: CInt

    public init?(rawValue: CInt) {
        guard rawValue >= 0 else { return nil }
        self.rawValue = rawValue
    }
}

public extension FileDescriptor {
    static let input: Self  = { FileDescriptor(rawValue: STDIN_FILENO)! }()
    static let output: Self = { FileDescriptor(rawValue: STDOUT_FILENO)! }()
    static let error: Self  = { FileDescriptor(rawValue: STDERR_FILENO)! }()
}

public extension FileDescriptor {
    init(with result: CInt) throws(Errno) {
        guard let descriptor = FileDescriptor(rawValue: result) else { throw Errno(rawValue: result) }
        self = descriptor
    }
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

extension FileDescriptor: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: UInt32) {
        self.init(rawValue: CInt(value))!
    }
}
