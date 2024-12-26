import LibC

#if canImport(Android)
private typealias Pointer = OpaquePointer
#else
private typealias Pointer = UnsafeMutablePointer<FILE>
#endif

public struct Document {
    public var path: Path
    public var mode: Mode
    
    private var allocator: Allocator<Pointer>
    private var descriptor: FileDescriptor?
    
    public init(path: Path, mode: Mode = .readAndWrite) {
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
    func seek(value: Int, option: CInt) throws {
        try result {
            fseek(try allocator.pointer(), value, option)
        }
    }
    
    func tell() throws -> Int {
        try result {
            ftell(try allocator.pointer())
        }
    }
    
    func write(array: [UInt8]) throws -> Int {
        try result {
            fwrite(array, 1, array.count, try allocator.pointer())
        }
    }
    
    func read(array: inout [UInt8], count: Int) throws -> Int {
        try result {
            fread(&array, 1, count, try allocator.pointer())
        }
    }
    
    func get(array: inout [UInt8]) throws {
        try result {
            fgets(&array, BUFSIZ, try allocator.pointer())
        }
    }
    
    func put(array: [UInt8]) throws {
        try result {
            fputs(array, try allocator.pointer())
        }
    }
    
    @discardableResult
    func result<T>(task: () throws -> T) throws -> T {
        do {
            return try task()
        } catch {
            throw Errno()
        }
    }
}

public extension Document {
    func size() throws -> Int {
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
