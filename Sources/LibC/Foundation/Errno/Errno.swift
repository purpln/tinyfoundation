public struct Errno: Error, RawRepresentable, Sendable {
    public var rawValue: CInt
    
    public init(rawValue: CInt) {
        self.rawValue = rawValue
    }
    
    public init() {
        self = .current
    }
}

extension Errno: CustomStringConvertible {
    public var description: String {
        guard let pointer = system_strerror(rawValue) else { return "unknown error" }
        return String(cString: pointer)
    }
}

extension Errno: Equatable {
    public static func == (lhs: Errno, rhs: Errno) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}

extension Errno: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

public extension Errno {
    static var current: Errno {
        get { Errno(rawValue: system_errno) }
        set { system_errno = newValue.rawValue }
    }
}

public extension Errno {
    //Operation not permitted
    @inlinable
    static var notPermited: Errno { Errno(rawValue: EPERM) }
    
    //No such file or directory
    @inlinable
    static var noSuchEntity: Errno { Errno(rawValue: ENOENT) }
    
    //No such process
    @inlinable
    static var noSuchProcess: Errno { Errno(rawValue: ESRCH) }
    
    //Interrupted system call
    @inlinable
    static var interrupted: Errno { Errno(rawValue: EINTR) }
    
    //Input/output error
    @inlinable
    static var inputOutputError: Errno { Errno(rawValue: EIO) }
    
    //Device not configured
    @inlinable
    static var notConfigured: Errno { Errno(rawValue: ENXIO) }
    
    //Argument list too long
    @inlinable
    static var argumentListTooLong: Errno { Errno(rawValue: E2BIG) }
    
    //Exec format error
    @inlinable
    static var executableFormatError: Errno { Errno(rawValue: ENOEXEC) }
    
    //Bad file descriptor
    @inlinable
    static var badFileDescriptor: Errno { Errno(rawValue: EBADF) }
    
    //No child processes
    @inlinable
    static var noChild: Errno { Errno(rawValue: ECHILD) }
    
    //Resource deadlock avoided
    @inlinable
    static var deadlock: Errno { Errno(rawValue: EDEADLK) }
    
    //Cannot allocate memory
    @inlinable
    static var allocateMemory: Errno { Errno(rawValue: ENOMEM) }
    
    //Permission denied
    @inlinable
    static var permissionDenied: Errno { Errno(rawValue: EACCES) }
    
    //Bad address
    @inlinable
    static var badAddress: Errno { Errno(rawValue: EFAULT) }
    
    //Block device required
    @inlinable
    static var blockRequired: Errno { Errno(rawValue: ENOTBLK) }
    
    //Resource busy
    @inlinable
    static var busy: Errno { Errno(rawValue: EBUSY) }
    
    //File exists
    @inlinable
    static var exists: Errno { Errno(rawValue: EEXIST) }
    
    //Cross-device link
    @inlinable
    static var crossDeviceLink: Errno { Errno(rawValue: EXDEV) }
    
    //Operation not supported by device
    @inlinable
    static var notSupported: Errno { Errno(rawValue: ENODEV) }
    
    //Not a directory
    @inlinable
    static var notDirectory: Errno { Errno(rawValue: ENOTDIR) }
    
    //Is a directory
    @inlinable
    static var isDirectory: Errno { Errno(rawValue: EISDIR) }
    
    //Invalid argument
    @inlinable
    static var invalidArgument: Errno { Errno(rawValue: EINVAL) }
    
    //Too many open files in system
    @inlinable
    static var tooManyOpenedSystem: Errno { Errno(rawValue: ENFILE) }
    
    //Too many open files
    @inlinable
    static var tooManyOpened: Errno { Errno(rawValue: EMFILE) }
    
    //Inappropriate ioctl for device
    @inlinable
    static var inappropriate: Errno { Errno(rawValue: ENOTTY) }
    
    //Text file busy
    @inlinable
    static var textFileBusy: Errno { Errno(rawValue: ETXTBSY) }
    
    //File too large
    @inlinable
    static var tooLarge: Errno { Errno(rawValue: EFBIG) }
    
    //No space left on device
    @inlinable
    static var noSpace: Errno { Errno(rawValue: ENOSPC) }
    
    //Illegal seek
    @inlinable
    static var illegalSeek: Errno { Errno(rawValue: ESPIPE) }
    
    //Read-only file system
    @inlinable
    static var readOnly: Errno { Errno(rawValue: EROFS) }
    
    //Too many links
    @inlinable
    static var tooManyLinks: Errno { Errno(rawValue: EMLINK) }
    
    //Broken pipe
    @inlinable
    static var brokenPipe: Errno { Errno(rawValue: EPIPE) }
    
    //Numerical argument out of domain
    @inlinable
    static var argumentOutOfDomain: Errno { Errno(rawValue: EDOM) }
    
    //Result too large
    @inlinable
    static var outOfRange: Errno { Errno(rawValue: ERANGE) }
    
    //Resource temporarily unavailable
    @inlinable
    static var again: Errno { Errno(rawValue: EAGAIN) }
    
    //Resource temporarily unavailable
    @inlinable
    static var wouldBlock: Errno { Errno(rawValue: EWOULDBLOCK) }
    
    //Operation now in progress
    @inlinable
    static var inProgress: Errno { Errno(rawValue: EINPROGRESS) }
    
    //Operation already in progress
    @inlinable
    static var alreadyInProgress: Errno { Errno(rawValue: EALREADY) }
    
    //Socket operation on non-socket
    @inlinable
    static var notSocket: Errno { Errno(rawValue: ENOTSOCK) }
    
    //Destination address required
    @inlinable
    static var destinationAddressRequired: Errno { Errno(rawValue: EDESTADDRREQ) }
    
    //Message too long
    @inlinable
    static var messageTooLong: Errno { Errno(rawValue: EMSGSIZE) }
    
    //Protocol wrong type for socket
    @inlinable
    static var wrongProtocolType: Errno { Errno(rawValue: EPROTOTYPE) }
    
    //Protocol not available
    @inlinable
    static var protocolNotAvailable: Errno { Errno(rawValue: ENOPROTOOPT) }
    
    //Protocol not supported
    @inlinable
    static var protocolNotSupported: Errno { Errno(rawValue: EPROTONOSUPPORT) }
    
    //Socket type not supported
    @inlinable
    static var socketNotSupported: Errno { Errno(rawValue: ESOCKTNOSUPPORT) }
    
    //Operation not supported
    @inlinable
    static var operationNotSupported: Errno { Errno(rawValue: ENOTSUP) }
    
    //Protocol family not supported
    @inlinable
    static var protocolFamilyNotSupported: Errno { Errno(rawValue: EPFNOSUPPORT) }
    
    //Address family not supported by protocol family
    @inlinable
    static var addressFamilyNotSupported: Errno { Errno(rawValue: EAFNOSUPPORT) }
    
    //Address already in use
    @inlinable
    static var alreadyInUse: Errno { Errno(rawValue: EADDRINUSE) }
    
    //Can\'t assign requested address
    @inlinable
    static var assignAddress: Errno { Errno(rawValue: EADDRNOTAVAIL) }
    
    //Network is down
    @inlinable
    static var networkDown: Errno { Errno(rawValue: ENETDOWN) }
    
    //Network is unreachable
    @inlinable
    static var networkUnreachable: Errno { Errno(rawValue: ENETUNREACH) }
    
    //Network dropped connection on reset
    @inlinable
    static var networkDroppedConnection: Errno { Errno(rawValue: ENETRESET) }
    
    //Software caused connection abort
    @inlinable
    static var connectionAbort: Errno { Errno(rawValue: ECONNABORTED) }
    
    //Connection reset by peer
    @inlinable
    static var connectionReset: Errno { Errno(rawValue: ECONNRESET) }
    
    //No buffer space available
    @inlinable
    static var noBufferSpace: Errno { Errno(rawValue: ENOBUFS) }
    
    //Socket is already connected
    @inlinable
    static var alreadyConnected: Errno { Errno(rawValue: EISCONN) }
    
    //Socket is not connected
    @inlinable
    static var notConnected: Errno { Errno(rawValue: ENOTCONN) }
    
    //Can\'t send after socket shutdown
    @inlinable
    static var socketShutdown: Errno { Errno(rawValue: ESHUTDOWN) }
    
    //Too many references: can\'t splice
    @inlinable
    static var tooManyReferences: Errno { Errno(rawValue: ETOOMANYREFS) }
    
    //Operation timed out
    @inlinable
    static var timeout: Errno { Errno(rawValue: ETIMEDOUT) }
    
    //Connection refused
    @inlinable
    static var connectionRefused: Errno { Errno(rawValue: ECONNREFUSED) }
    
    //Too many levels of symbolic links
    @inlinable
    static var tooManySymbolicLinks: Errno { Errno(rawValue: ELOOP) }
    
    //File name too long
    @inlinable
    static var nameTooLong: Errno { Errno(rawValue: ENAMETOOLONG) }
    
    //Host is down
    @inlinable
    static var hostDown: Errno { Errno(rawValue: EHOSTDOWN) }
    
    //No route to host
    @inlinable
    static var hostUnreachable: Errno { Errno(rawValue: EHOSTUNREACH) }
    
    //Directory not empty
    @inlinable
    static var directoryNotEmpty: Errno { Errno(rawValue: ENOTEMPTY) }
    /*
    //Too many processes
    @inlinable
    static var tooManyProcesses: Errno { Errno(rawValue: EPROCLIM) }
    */
    //Too many users
    @inlinable
    static var tooManyUsers: Errno { Errno(rawValue: EUSERS) }
    
    //Disc quota exceeded
    @inlinable
    static var discQuotaExceeded: Errno { Errno(rawValue: EDQUOT) }
    
    //Stale NFS file handle
    @inlinable
    static var stale: Errno { Errno(rawValue: ESTALE) }
    
    //Too many levels of remote in path
    @inlinable
    static var tooManyRemote: Errno { Errno(rawValue: EREMOTE) }
    /*
    //Program version wrong
    @inlinable
    static var wrongVersion: Errno { Errno(rawValue: EPROGMISMATCH) }
    
    //Bad procedure for program
    @inlinable
    static var unavailableProcedure: Errno { Errno(rawValue: EPROCUNAVAIL) }
    */
    //No locks available
    @inlinable
    static var noLocks: Errno { Errno(rawValue: ENOLCK) }
    
    //Function not implemented
    @inlinable
    static var notImplemented: Errno { Errno(rawValue: ENOSYS) }
    /*
    //Inappropriate file type or format
    @inlinable
    static var inappropriateFile: Errno { Errno(rawValue: EFTYPE) }
    
    //Authentication error
    @inlinable
    static var authentication: Errno { Errno(rawValue: EAUTH) }
    
    //Need authenticator
    @inlinable
    static var authenticationNeeded: Errno { Errno(rawValue: ENEEDAUTH) }
    
    //Device power is off
    @inlinable
    static var powerOff: Errno { Errno(rawValue: EPWROFF) }
    
    //Device error
    @inlinable
    static var device: Errno { Errno(rawValue: EDEVERR) }
    */
    //Value too large to be stored in data type
    @inlinable
    static var overflow: Errno { Errno(rawValue: EOVERFLOW) }
    /*
    //Bad executable (or shared library)
    @inlinable
    static var badExecutable: Errno { Errno(rawValue: EBADEXEC) }
    
    //Bad CPU type in executable
    @inlinable
    static var badArchitecture: Errno { Errno(rawValue: EBADARCH) }
    
    //Shared library version mismatch
    @inlinable
    static var libraryVersionMismatch: Errno { Errno(rawValue: ESHLIBVERS) }
    
    //Malformed Mach-o file
    @inlinable
    static var badMach: Errno { Errno(rawValue: EBADMACHO) }
    */
    //Operation canceled
    @inlinable
    static var canceled: Errno { Errno(rawValue: ECANCELED) }
    
    //Identifier removed
    @inlinable
    static var removedIdentifier: Errno { Errno(rawValue: EIDRM) }
    
    //No message of desired type
    @inlinable
    static var noMessage: Errno { Errno(rawValue: ENOMSG) }
    
    //Illegal byte sequence
    @inlinable
    static var illegalSequence: Errno { Errno(rawValue: EILSEQ) }
    /*
    //Attribute not found
    @inlinable
    static var noAttribute: Errno { Errno(rawValue: ENOATTR) }
    */
    //Bad message
    @inlinable
    static var badMessage: Errno { Errno(rawValue: EBADMSG) }
}
