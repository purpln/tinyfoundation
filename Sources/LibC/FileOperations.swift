extension FileDescriptor {
    public func close() throws { try _close().get() }
    
    @usableFromInline
    internal func _close() -> Result<(), Errno> {
        nothingOrErrno(retryOnInterrupt: false) { system_close(self) }
    }
}

extension FileDescriptor {
    public func read(
        into buffer: UnsafeMutableRawBufferPointer,
        retryOnInterrupt: Bool = true
    ) throws(Errno) -> Int {
        try _read(into: buffer, retryOnInterrupt: retryOnInterrupt).get()
    }
    
    @usableFromInline
    internal func _read(
        into buffer: UnsafeMutableRawBufferPointer,
        retryOnInterrupt: Bool
    ) -> Result<Int, Errno> {
        valueOrErrno(retryOnInterrupt: retryOnInterrupt) {
            system_read(self, buffer.baseAddress, buffer.count)
        }
    }
    
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
    
    @usableFromInline
    internal func _read(
        fromAbsoluteOffset offset: Int64,
        into buffer: UnsafeMutableRawBufferPointer,
        retryOnInterrupt: Bool
    ) -> Result<Int, Errno> {
        valueOrErrno(retryOnInterrupt: retryOnInterrupt) {
            system_pread(self, buffer.baseAddress, buffer.count, _COffT(offset))
        }
    }
}

extension FileDescriptor {
    public func write(
        _ buffer: UnsafeRawBufferPointer,
        retryOnInterrupt: Bool = true
    ) throws(Errno) -> Int {
        try _write(buffer, retryOnInterrupt: retryOnInterrupt).get()
    }
    
    @usableFromInline
    internal func _write(
        _ buffer: UnsafeRawBufferPointer,
        retryOnInterrupt: Bool
    ) -> Result<Int, Errno> {
        valueOrErrno(retryOnInterrupt: retryOnInterrupt) {
            system_write(self, buffer.baseAddress, buffer.count)
        }
    }
    
    public func write(
        toAbsoluteOffset offset: Int64,
        _ buffer: UnsafeRawBufferPointer,
        retryOnInterrupt: Bool = true
    ) throws(Errno) -> Int {
        try _write(toAbsoluteOffset: offset, buffer, retryOnInterrupt: retryOnInterrupt).get()
    }
    
    @usableFromInline
    internal func _write(
        toAbsoluteOffset offset: Int64,
        _ buffer: UnsafeRawBufferPointer,
        retryOnInterrupt: Bool
    ) -> Result<Int, Errno> {
        valueOrErrno(retryOnInterrupt: retryOnInterrupt) {
            system_pwrite(self, buffer.baseAddress, buffer.count, _COffT(offset))
        }
    }
}

#if !os(WASI)
extension FileDescriptor {
    public func duplicate(
        as target: FileDescriptor? = nil,
        retryOnInterrupt: Bool = true
    ) throws(Errno) -> FileDescriptor {
        try _duplicate(as: target, retryOnInterrupt: retryOnInterrupt).get()
    }
    
    @usableFromInline
    internal func _duplicate(
        as target: FileDescriptor?,
        retryOnInterrupt: Bool
    ) -> Result<FileDescriptor, Errno> {
        valueOrErrno(retryOnInterrupt: retryOnInterrupt) {
            if let target = target {
                return system_dup2(self.rawValue, target.rawValue)
            }
            return system_dup(self.rawValue)
        }.map(FileDescriptor.init(rawValue:))
    }
}

extension FileDescriptor {
    public static func pipe() throws(Errno) -> (readEnd: FileDescriptor, writeEnd: FileDescriptor) {
        try _pipe().get()
    }
    
    @usableFromInline
    internal static func _pipe() -> Result<(readEnd: FileDescriptor, writeEnd: FileDescriptor), Errno> {
        var tunnel: (Int32, Int32) = (-1, -1)
        return withUnsafeMutablePointer(to: &tunnel) { pointer in
            pointer.withMemoryRebound(to: Int32.self, capacity: 2) { tunnel in
                valueOrErrno(retryOnInterrupt: false) {
                    system_pipe(tunnel)
                }.map { _ in (FileDescriptor(rawValue: tunnel[0]), FileDescriptor(rawValue: tunnel[1])) }
            }
        }
    }
}
#endif
