import TinySystem

extension FileDescriptor {
    @_alwaysEmitIntoClient
    public static func open(
        _ path: String,
        _ mode: FileDescriptor.AccessMode,
        options: FileDescriptor.OpenOptions = FileDescriptor.OpenOptions(),
        permissions: FilePermissions? = nil,
        retryOnInterrupt: Bool = true
    ) throws -> FileDescriptor {
#if os(Windows)
        try path.withPlatformString {
            try FileDescriptor.open(
                $0, mode, options: options, permissions: permissions, retryOnInterrupt: retryOnInterrupt
            )
        }
#else
        try path.withCString {
            try FileDescriptor.open(
                $0, mode, options: options, permissions: permissions, retryOnInterrupt: retryOnInterrupt
            )
        }
#endif
    }
    
#if compiler(>=6.0)
#if os(Windows)
    @_alwaysEmitIntoClient
    public static func open(
        _ path: UnsafePointer<PlatformChar>,
        _ mode: FileDescriptor.AccessMode,
        options: FileDescriptor.OpenOptions = FileDescriptor.OpenOptions(),
        permissions: FilePermissions? = nil,
        retryOnInterrupt: Bool = true
    ) throws(Errno) -> FileDescriptor {
        try FileDescriptor._open(
            path, mode, options: options, permissions: permissions, retryOnInterrupt: retryOnInterrupt
        ).get()
    }
#endif
#else
#if os(Windows)
    @_alwaysEmitIntoClient
    public static func open(
        _ path: UnsafePointer<PlatformChar>,
        _ mode: FileDescriptor.AccessMode,
        options: FileDescriptor.OpenOptions = FileDescriptor.OpenOptions(),
        permissions: FilePermissions? = nil,
        retryOnInterrupt: Bool = true
    ) throws -> FileDescriptor {
        try FileDescriptor._open(
            path, mode, options: options, permissions: permissions, retryOnInterrupt: retryOnInterrupt
        ).get()
    }
#endif
#endif
    
#if os(Windows)
    @usableFromInline
    internal static func _open(
        _ path: UnsafePointer<PlatformChar>,
        _ mode: FileDescriptor.AccessMode,
        options: FileDescriptor.OpenOptions,
        permissions: FilePermissions?,
        retryOnInterrupt: Bool
    ) -> Result<FileDescriptor, Errno> {
        let oFlag = mode.rawValue | options.rawValue
        let descOrError: Result<CInt, Errno> = valueOrErrno(retryOnInterrupt: retryOnInterrupt) {
            if let permissions = permissions {
                return system_open(path, oFlag, permissions.rawValue)
            }
            return system_open(path, oFlag)
        }
        return descOrError.map { FileDescriptor(rawValue: $0) }
    }
#else
#if compiler(>=6.0)
    @_alwaysEmitIntoClient
    public static func open(
        _ path: UnsafePointer<CChar>,
        _ mode: FileDescriptor.AccessMode,
        options: FileDescriptor.OpenOptions = FileDescriptor.OpenOptions(),
        permissions: FilePermissions? = nil,
        retryOnInterrupt: Bool = true
    ) throws(Errno) -> FileDescriptor {
        try FileDescriptor._open(
            path, mode, options: options, permissions: permissions, retryOnInterrupt: retryOnInterrupt
        ).get()
    }
#else
    @_alwaysEmitIntoClient
    public static func open(
        _ path: UnsafePointer<CChar>,
        _ mode: FileDescriptor.AccessMode,
        options: FileDescriptor.OpenOptions = FileDescriptor.OpenOptions(),
        permissions: FilePermissions? = nil,
        retryOnInterrupt: Bool = true
    ) throws -> FileDescriptor {
        try FileDescriptor._open(
            path, mode, options: options, permissions: permissions, retryOnInterrupt: retryOnInterrupt
        ).get()
    }
#endif
    
    @usableFromInline
    internal static func _open(
        _ path: UnsafePointer<CChar>,
        _ mode: FileDescriptor.AccessMode,
        options: FileDescriptor.OpenOptions,
        permissions: FilePermissions?,
        retryOnInterrupt: Bool
    ) -> Result<FileDescriptor, Errno> {
        let oFlag = mode.rawValue | options.rawValue
        let descOrError: Result<CInt, Errno> = valueOrErrno(retryOnInterrupt: retryOnInterrupt) {
            if let permissions = permissions {
                return system_open(path, oFlag, permissions.rawValue)
            }
            precondition(!options.contains(.create), "Create must be given permissions")
            return system_open(path, oFlag)
        }
        return descOrError.map { FileDescriptor(rawValue: $0) }
    }
#endif
    
#if compiler(>=6.0)
    @_alwaysEmitIntoClient
    public func close() throws(Errno) { try _close().get() }
#else
    @_alwaysEmitIntoClient
    public func close() throws { try _close().get() }
#endif
    
    @usableFromInline
    internal func _close() -> Result<(), Errno> {
        nothingOrErrno(retryOnInterrupt: false) {
            system_close(rawValue)
        }
    }
    
#if compiler(>=6.0)
    @_alwaysEmitIntoClient
    @discardableResult
    public func seek(
        offset: Int64, from whence: FileDescriptor.SeekOrigin
    ) throws(Errno) -> Int64 {
        try _seek(offset: offset, from: whence).get()
    }
#else
    @_alwaysEmitIntoClient
    @discardableResult
    public func seek(
        offset: Int64, from whence: FileDescriptor.SeekOrigin
    ) throws -> Int64 {
        try _seek(offset: offset, from: whence).get()
    }
#endif
    
    @usableFromInline
    internal func _seek(
        offset: Int64, from whence: FileDescriptor.SeekOrigin
    ) -> Result<Int64, Errno> {
        valueOrErrno(retryOnInterrupt: false) {
            Int64(system_lseek(rawValue, PlatformOffset(offset), whence.rawValue))
        }
    }
    
#if compiler(>=6.0)
    @_alwaysEmitIntoClient
    @available(*, unavailable, renamed: "seek")
    public func lseek(
        offset: Int64, from whence: FileDescriptor.SeekOrigin
    ) throws(Errno) -> Int64 {
        try seek(offset: offset, from: whence)
    }
#else
    @_alwaysEmitIntoClient
    @available(*, unavailable, renamed: "seek")
    public func lseek(
        offset: Int64, from whence: FileDescriptor.SeekOrigin
    ) throws -> Int64 {
        try seek(offset: offset, from: whence)
    }
#endif
    
#if compiler(>=6.0)
    @_alwaysEmitIntoClient
    public func read(
        into buffer: UnsafeMutableRawBufferPointer,
        retryOnInterrupt: Bool = true
    ) throws(Errno) -> Int {
        try _read(into: buffer, retryOnInterrupt: retryOnInterrupt).get()
    }
#else
    @_alwaysEmitIntoClient
    public func read(
        into buffer: UnsafeMutableRawBufferPointer,
        retryOnInterrupt: Bool = true
    ) throws -> Int {
        try _read(into: buffer, retryOnInterrupt: retryOnInterrupt).get()
    }
#endif
    
    @usableFromInline
    internal func _read(
        into buffer: UnsafeMutableRawBufferPointer,
        retryOnInterrupt: Bool
    ) -> Result<Int, Errno> {
        valueOrErrno(retryOnInterrupt: retryOnInterrupt) {
            system_read(rawValue, buffer.baseAddress, buffer.count)
        }
    }
    
#if compiler(>=6.0)
    @_alwaysEmitIntoClient
    public func read(
        fromAbsoluteOffset offset: Int64,
        into buffer: UnsafeMutableRawBufferPointer,
        retryOnInterrupt: Bool = true
    ) throws(Errno) -> Int {
        try _read(
            fromAbsoluteOffset: offset,
            into: buffer,
            retryOnInterrupt: retryOnInterrupt
        ).get()
    }
#else
    @_alwaysEmitIntoClient
    public func read(
        fromAbsoluteOffset offset: Int64,
        into buffer: UnsafeMutableRawBufferPointer,
        retryOnInterrupt: Bool = true
    ) throws -> Int {
        try _read(
            fromAbsoluteOffset: offset,
            into: buffer,
            retryOnInterrupt: retryOnInterrupt
        ).get()
    }
#endif
    
    @usableFromInline
    internal func _read(
        fromAbsoluteOffset offset: Int64,
        into buffer: UnsafeMutableRawBufferPointer,
        retryOnInterrupt: Bool
    ) -> Result<Int, Errno> {
        valueOrErrno(retryOnInterrupt: retryOnInterrupt) {
            system_pread(rawValue, buffer.baseAddress, buffer.count, PlatformOffset(offset))
        }
    }
    
#if compiler(>=6.0)
    @_alwaysEmitIntoClient
    @available(*, unavailable, renamed: "read")
    public func pread(
        fromAbsoluteOffset offset: Int64,
        into buffer: UnsafeMutableRawBufferPointer,
        retryOnInterrupt: Bool = true
    ) throws(Errno) -> Int {
        try read(
            fromAbsoluteOffset: offset,
            into: buffer,
            retryOnInterrupt: retryOnInterrupt
        )
    }
#else
    @_alwaysEmitIntoClient
    @available(*, unavailable, renamed: "read")
    public func pread(
        fromAbsoluteOffset offset: Int64,
        into buffer: UnsafeMutableRawBufferPointer,
        retryOnInterrupt: Bool = true
    ) throws -> Int {
        try read(
            fromAbsoluteOffset: offset,
            into: buffer,
            retryOnInterrupt: retryOnInterrupt
        )
    }
#endif
    
#if compiler(>=6.0)
    @_alwaysEmitIntoClient
    public func write(
        _ buffer: UnsafeRawBufferPointer,
        retryOnInterrupt: Bool = true
    ) throws(Errno) -> Int {
        try _write(buffer, retryOnInterrupt: retryOnInterrupt).get()
    }
#else
    @_alwaysEmitIntoClient
    public func write(
        _ buffer: UnsafeRawBufferPointer,
        retryOnInterrupt: Bool = true
    ) throws -> Int {
        try _write(buffer, retryOnInterrupt: retryOnInterrupt).get()
    }
#endif
    
    @usableFromInline
    internal func _write(
        _ buffer: UnsafeRawBufferPointer,
        retryOnInterrupt: Bool
    ) -> Result<Int, Errno> {
        valueOrErrno(retryOnInterrupt: retryOnInterrupt) {
            system_write(rawValue, buffer.baseAddress, buffer.count)
        }
    }
    
#if compiler(>=6.0)
    @_alwaysEmitIntoClient
    public func write(
        toAbsoluteOffset offset: Int64,
        _ buffer: UnsafeRawBufferPointer,
        retryOnInterrupt: Bool = true
    ) throws(Errno) -> Int {
        try _write(toAbsoluteOffset: offset, buffer, retryOnInterrupt: retryOnInterrupt).get()
    }
#else
    @_alwaysEmitIntoClient
    public func write(
        toAbsoluteOffset offset: Int64,
        _ buffer: UnsafeRawBufferPointer,
        retryOnInterrupt: Bool = true
    ) throws -> Int {
        try _write(toAbsoluteOffset: offset, buffer, retryOnInterrupt: retryOnInterrupt).get()
    }
#endif
    
    @usableFromInline
    internal func _write(
        toAbsoluteOffset offset: Int64,
        _ buffer: UnsafeRawBufferPointer,
        retryOnInterrupt: Bool
    ) -> Result<Int, Errno> {
        valueOrErrno(retryOnInterrupt: retryOnInterrupt) {
            system_pwrite(rawValue, buffer.baseAddress, buffer.count, PlatformOffset(offset))
        }
    }
    
#if compiler(>=6.0)
    @_alwaysEmitIntoClient
    @available(*, unavailable, renamed: "write")
    public func pwrite(
        toAbsoluteOffset offset: Int64,
        into buffer: UnsafeRawBufferPointer,
        retryOnInterrupt: Bool = true
    ) throws(Errno) -> Int {
        try write(
            toAbsoluteOffset: offset,
            buffer,
            retryOnInterrupt: retryOnInterrupt)
    }
#else
    @_alwaysEmitIntoClient
    @available(*, unavailable, renamed: "write")
    public func pwrite(
        toAbsoluteOffset offset: Int64,
        into buffer: UnsafeRawBufferPointer,
        retryOnInterrupt: Bool = true
    ) throws -> Int {
        try write(
            toAbsoluteOffset: offset,
            buffer,
            retryOnInterrupt: retryOnInterrupt)
    }
#endif
}

#if !os(WASI)
extension FileDescriptor {
#if compiler(>=6.0)
    @_alwaysEmitIntoClient
    public func duplicate(
        as target: FileDescriptor? = nil,
        retryOnInterrupt: Bool = true
    ) throws(Errno) -> FileDescriptor {
        try _duplicate(as: target, retryOnInterrupt: retryOnInterrupt).get()
    }
#else
    @_alwaysEmitIntoClient
    public func duplicate(
        as target: FileDescriptor? = nil,
        retryOnInterrupt: Bool = true
    ) throws -> FileDescriptor {
        try _duplicate(as: target, retryOnInterrupt: retryOnInterrupt).get()
    }
#endif
    
    @usableFromInline
    internal func _duplicate(
        as target: FileDescriptor?,
        retryOnInterrupt: Bool
    ) -> Result<FileDescriptor, Errno> {
        valueOrErrno(retryOnInterrupt: retryOnInterrupt) {
            if let target = target {
                return system_dup2(rawValue, target.rawValue)
            }
            return system_dup(rawValue)
        }.map(FileDescriptor.init(rawValue:))
    }
}
#endif

#if !os(WASI)
extension FileDescriptor {
#if compiler(>=6.0)
    @_alwaysEmitIntoClient
    public static func pipe() throws(Errno) -> (read: FileDescriptor, write: FileDescriptor) {
        try _pipe().get()
    }
#else
    @_alwaysEmitIntoClient
    public static func pipe() throws -> (read: FileDescriptor, write: FileDescriptor) {
        try _pipe().get()
    }
#endif
    
    @usableFromInline
    internal static func _pipe() -> Result<(read: FileDescriptor, write: FileDescriptor), Errno> {
        var tunnel: (CInt, CInt) = (-1, -1)
        return withUnsafeMutablePointer(to: &tunnel) { pointer in
            pointer.withMemoryRebound(to: CInt.self, capacity: 2) { tunnel in
                valueOrErrno(retryOnInterrupt: false) {
                    system_pipe(tunnel)
                }.map { _ in (.init(rawValue: tunnel[0]), .init(rawValue: tunnel[1])) }
            }
        }
    }
}
#endif

extension FileDescriptor {
#if compiler(>=6.0)
    @_alwaysEmitIntoClient
    public func resize(
        to newSize: Int64,
        retryOnInterrupt: Bool = true
    ) throws(Errno) {
        try _resize(
            to: newSize,
            retryOnInterrupt: retryOnInterrupt
        ).get()
    }
#else
    @_alwaysEmitIntoClient
    public func resize(
        to newSize: Int64,
        retryOnInterrupt: Bool = true
    ) throws {
        try _resize(
            to: newSize,
            retryOnInterrupt: retryOnInterrupt
        ).get()
    }
#endif
    
    
    @usableFromInline
    internal func _resize(
        to newSize: Int64,
        retryOnInterrupt: Bool
    ) -> Result<(), Errno> {
        nothingOrErrno(retryOnInterrupt: retryOnInterrupt) {
            system_ftruncate(rawValue, PlatformOffset(newSize))
        }
    }
}

extension FilePermissions {
    internal static var creationMask: FilePermissions {
        get {
            let oldMask = _umask(0o22)
            _umask(oldMask)
            return FilePermissions(rawValue: oldMask)
        }
        set {
            _umask(newValue.rawValue)
        }
    }
#if compiler(>=6.0)
    internal static func withCreationMask<R, E: Error>(
        _ permissions: FilePermissions,
        body: () throws(E) -> R
    ) throws(E) -> R {
        let oldMask = _umask(permissions.rawValue)
        defer {
            _umask(oldMask)
        }
        return try body()
    }
#else
    internal static func withCreationMask<R>(
        _ permissions: FilePermissions,
        body: () throws -> R
    ) rethrows -> R {
        let oldMask = _umask(permissions.rawValue)
        defer {
            _umask(oldMask)
        }
        return try body()
    }
#endif
    @discardableResult
    internal static func _umask(_ mode: PlatformMode) -> PlatformMode {
        return system_umask(mode)
    }
}
