import LibC

#if canImport(Android) || os(WASI)
private typealias Pointer = OpaquePointer
#else
private typealias Pointer = UnsafeMutablePointer<FILE>
#endif

public struct Document {
    public var path: Path
    public var mode: Mode
    
    private var allocator: Allocator<Pointer>
    private var descriptor: FileDescriptor?
    
    public init(path: Path, mode: Mode) {
        self.path = path
        self.mode = mode
        
        let path = path.resolved.rawValue
        allocator = Allocator(open: {
            fopen(path, mode.rawValue)
        }, close: { pointer in
            fclose(pointer)
        })
    }
}

private extension Document {
    func seek(value: Int, option: CInt) throws(Errno) {
        try result { pointer throws(Errno) -> Void in
            try nothingOrErrno(retryOnInterrupt: false, {
                fseek(pointer, value, option)
            }).get()
        }
    }
    
    func tell() throws(Errno) -> Int {
        try result { pointer throws(Errno) -> Int in
            try valueOrErrno(retryOnInterrupt: false, {
                ftell(pointer)
            }).get()
        }
    }
    
    func write(array: [UInt8]) throws(Errno) -> Int {
        try result { pointer throws(Errno) -> Int in
            try valueOrErrno(retryOnInterrupt: false, {
                fwrite(array, 1, array.count, pointer)
            }).get()
        }
    }
    
    func read(array: inout [UInt8], count: Int) throws(Errno) -> Int {
        try result { pointer throws(Errno) -> Int in
            try valueOrErrno(retryOnInterrupt: false, {
                fread(&array, 1, count, pointer)
            }).get()
        }
    }
    
    func get(array: inout [UInt8]) throws(Errno) {
        try result { pointer in
            fgets(&array, BUFSIZ, pointer)
        }
    }
    
    func put(array: [UInt8]) throws(Errno) {
        try result { pointer throws(Errno) -> Void in
            try nothingOrErrno(retryOnInterrupt: false, {
                fputs(array, pointer)
            }).get()
        }
    }
    
    @discardableResult
    func result<T>(task: (Pointer) throws(Errno) -> T) throws(Errno) -> T {
        do {
            let pointer = try allocator.pointer()
            return try task(pointer)
        } catch {
            throw error
        }
    }
}

public extension Document {
    func size() throws(Errno) -> Int {
        let offset = try tell()
        try seek(value: 0, option: SEEK_END)
        let size = try tell()
        try seek(value: offset, option: SEEK_SET)
        return size
    }
    
    func read() throws -> [UInt8] {
        let offset = try tell()
        
        try seek(value: 0, option: SEEK_END)
        let count = try tell()
        var array = [UInt8](repeating: 0, count: count)
        
        try seek(value: 0, option: SEEK_SET)
        let read = try read(array: &array, count: count)
        try seek(value: offset, option: SEEK_SET)
        
        guard read == count else { throw DocumentError.read }
        return array
    }
    
    func write(bytes: [UInt8]) throws {
        let count = bytes.count
        let written = try write(array: bytes)
        guard written == count else { throw DocumentError.write }
    }
    /*
    mutating func lock(type: LockType = .exclusive, blocking: Bool = true) throws {
        let path = path.resolved.rawValue
        let result = open(path, O_WRONLY | O_CREAT | O_CLOEXEC, 0o666)
        descriptor = try Descriptor(with: result)
        
        var flags: CInt
        switch type {
        case .exclusive: flags = LOCK_EX
        case .shared: flags = LOCK_SH
        }
        if !blocking {
            flags |= LOCK_NB
        }
        while true {
            if flock(descriptor!.rawValue, flags) == 0 {
                break
            }
            if errno == EINTR { continue }
            throw DocumentError.unableToAquireLock
        }
    }
    
    func unlock() {
        guard let descriptor = descriptor else { return }
        flock(descriptor.rawValue, LOCK_UN)
    }
    */
}

public extension Document {
    func write<Sequence: Collection>(_ sequence: Sequence) throws where Sequence.Iterator.Element == UInt8 {
        try write(bytes: Array(sequence))
    }
}
