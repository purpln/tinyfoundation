public struct Errno: Error, RawRepresentable, Equatable, Sendable, CustomStringConvertible  {
    public var rawValue: CInt
    
    public init(rawValue: CInt) {
        self.rawValue = rawValue
    }
    
    public init() {
        self.init(rawValue: errno)
    }
    
    public var description: String {
        String(cString: strerror(rawValue))
    }
}

public extension Errno {
    static let again = Errno(rawValue: EAGAIN)
    static let wouldBlock = Errno(rawValue: EWOULDBLOCK)
    static let inProgress = Errno(rawValue: EINPROGRESS)
    static let invalidArgument = Errno(rawValue: EINVAL)
    static let connectionReset = Errno(rawValue: ECONNRESET)
    static let alreadyInUse = Errno(rawValue: EADDRINUSE)
    
    static let notPermited = Errno(rawValue: EPERM) //Operation not permitted
    static let noSuchEntity = Errno(rawValue: ENOENT) //No such file or directory
    static let noSuchProcess = Errno(rawValue: ESRCH) //No such process
    static let interrupted = Errno(rawValue: EINTR) //Interrupted system call
    static let inputOutputError = Errno(rawValue: EIO) //Input/output error
    static let notConfigured = Errno(rawValue: ENXIO) //Device not configured
    static let argumentListTooLong = Errno(rawValue: E2BIG) //Argument list too long
    static let executableFormatError = Errno(rawValue: ENOEXEC) //Exec format error
    static let badFileDescriptor = Errno(rawValue: EBADF) //Bad file descriptor
    static let noChild = Errno(rawValue: ECHILD) //No child processes
}
