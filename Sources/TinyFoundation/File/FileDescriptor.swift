import TinySystem

public struct FileDescriptor: RawRepresentable, Sendable, Equatable, Hashable {
    public let rawValue: CInt
    
    public init(rawValue: CInt) {
        self.rawValue = rawValue
    }
}

public extension FileDescriptor {
    @inlinable
    static var input: FileDescriptor  { FileDescriptor(rawValue: _STDIN_FILENO) }
    
    @inlinable
    static var output: FileDescriptor { FileDescriptor(rawValue: _STDOUT_FILENO) }
    
    @inlinable
    static var error: FileDescriptor  { FileDescriptor(rawValue: _STDERR_FILENO) }
}

extension FileDescriptor {
    @frozen
    public struct AccessMode: RawRepresentable, Sendable, Hashable, Codable {
        @_alwaysEmitIntoClient
        public var rawValue: CInt
        
        @_alwaysEmitIntoClient
        public init(rawValue: CInt) { self.rawValue = rawValue }
        
        @_alwaysEmitIntoClient
        public static var readOnly: AccessMode { AccessMode(rawValue: _O_RDONLY) }
        
        @_alwaysEmitIntoClient
        public static var writeOnly: AccessMode { AccessMode(rawValue: _O_WRONLY) }
        
        @_alwaysEmitIntoClient
        public static var readWrite: AccessMode { AccessMode(rawValue: _O_RDWR) }
    }
    
    @frozen
    public struct OpenOptions: OptionSet, Sendable, Hashable, Codable {
        @_alwaysEmitIntoClient
        public var rawValue: CInt
        
        @_alwaysEmitIntoClient
        public init(rawValue: CInt) { self.rawValue = rawValue }
        
#if !os(Windows)
        @_alwaysEmitIntoClient
        public static var nonBlocking: OpenOptions { .init(rawValue: _O_NONBLOCK) }
#endif
        
        @_alwaysEmitIntoClient
        public static var append: OpenOptions { .init(rawValue: _O_APPEND) }
        
        @_alwaysEmitIntoClient
        public static var create: OpenOptions { .init(rawValue: _O_CREAT) }
        
        @_alwaysEmitIntoClient
        public static var truncate: OpenOptions { .init(rawValue: _O_TRUNC) }
        
        @_alwaysEmitIntoClient
        public static var exclusiveCreate: OpenOptions { .init(rawValue: _O_EXCL) }
        
#if canImport(Darwin)
        @_alwaysEmitIntoClient
        public static var sharedLock: OpenOptions { .init(rawValue: _O_SHLOCK) }
        
        @_alwaysEmitIntoClient
        public static var exclusiveLock: OpenOptions { .init(rawValue: _O_EXLOCK) }
#endif
        
#if !os(Windows)
        @_alwaysEmitIntoClient
        public static var noFollow: OpenOptions { .init(rawValue: _O_NOFOLLOW) }
        
        @_alwaysEmitIntoClient
        public static var directory: OpenOptions { .init(rawValue: _O_DIRECTORY) }
#endif
        
#if canImport(Darwin)
        @_alwaysEmitIntoClient
        public static var symlink: OpenOptions { .init(rawValue: _O_SYMLINK) }
        
        @_alwaysEmitIntoClient
        public static var eventOnly: OpenOptions { .init(rawValue: _O_EVTONLY) }
#endif
        
#if !os(Windows)
        @_alwaysEmitIntoClient
        public static var closeOnExec: OpenOptions { .init(rawValue: _O_CLOEXEC) }
#endif
    }
    
    @frozen
    public struct SeekOrigin: RawRepresentable, Sendable, Hashable, Codable {
        @_alwaysEmitIntoClient
        public var rawValue: CInt
        
        @_alwaysEmitIntoClient
        public init(rawValue: CInt) { self.rawValue = rawValue }
        
        @_alwaysEmitIntoClient
        public static var start: SeekOrigin { SeekOrigin(rawValue: _SEEK_SET) }
        
        @_alwaysEmitIntoClient
        public static var current: SeekOrigin { SeekOrigin(rawValue: _SEEK_CUR) }
        
        @_alwaysEmitIntoClient
        public static var end: SeekOrigin { SeekOrigin(rawValue: _SEEK_END) }
        
#if canImport(Darwin)
        @_alwaysEmitIntoClient
        public static var nextHole: SeekOrigin { SeekOrigin(rawValue: _SEEK_HOLE) }
        
        @_alwaysEmitIntoClient
        public static var nextData: SeekOrigin { SeekOrigin(rawValue: _SEEK_DATA) }
#endif
        
    }
}

extension FileDescriptor.AccessMode: CustomStringConvertible {
    @inline(never)
    public var description: String {
        switch self {
        case .readOnly: return "readOnly"
        case .writeOnly: return "writeOnly"
        case .readWrite: return "readWrite"
        default: return "\(Self.self)(rawValue: \(rawValue))"
        }
    }
}

extension FileDescriptor.SeekOrigin: CustomStringConvertible {
    @inline(never)
    public var description: String {
        switch self {
        case .start: return "start"
        case .current: return "current"
        case .end: return "end"
#if canImport(Darwin)
        case .nextHole: return "nextHole"
        case .nextData: return "nextData"
#endif
        default: return "\(Self.self)(rawValue: \(rawValue))"
        }
    }
}

extension FileDescriptor.OpenOptions: CustomStringConvertible {
    /// A textual representation of the open options.
    @inline(never)
    public var description: String {
#if canImport(Darwin)
        let descriptions: [(Element, StaticString)] = [
            (.nonBlocking, ".nonBlocking"),
            (.append, ".append"),
            (.create, ".create"),
            (.truncate, ".truncate"),
            (.exclusiveCreate, ".exclusiveCreate"),
            (.sharedLock, ".sharedLock"),
            (.exclusiveLock, ".exclusiveLock"),
            (.noFollow, ".noFollow"),
            (.symlink, ".symlink"),
            (.eventOnly, ".eventOnly"),
            (.closeOnExec, ".closeOnExec")
        ]
#elseif os(Windows)
        let descriptions: [(Element, StaticString)] = [
            (.append, ".append"),
            (.create, ".create"),
            (.truncate, ".truncate"),
            (.exclusiveCreate, ".exclusiveCreate"),
        ]
#else
        let descriptions: [(Element, StaticString)] = [
            (.nonBlocking, ".nonBlocking"),
            (.append, ".append"),
            (.create, ".create"),
            (.truncate, ".truncate"),
            (.exclusiveCreate, ".exclusiveCreate"),
            (.noFollow, ".noFollow"),
            (.closeOnExec, ".closeOnExec")
        ]
#endif
        
        return buildDescription(descriptions)
    }
}
