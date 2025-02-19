import LibC

#if os(Linux) || os(Android) || os(WASI)
private typealias Pointer = OpaquePointer
#else
private typealias Pointer = UnsafeMutablePointer<DIR>
#endif

public struct Directory {
    public var path: Path
    
    private var allocator: Allocator<Pointer>
    
    public init(path: Path) {
        self.path = path
        
        let path = path.resolved.rawValue
        allocator = Allocator(open: {
            opendir(path)
        }, close: { pointer in
            closedir(pointer)
        })
    }
}

public extension Directory {
    func contents() throws -> [String] {
        let pointer = try allocator.pointer()
        var results = [String]()
        while let entity = readdir(pointer) {
#if !os(WASI)
            var name = entity.pointee.d_name
            let path = withUnsafePointer(to: &name) { pointer -> String in
                let buffer = pointer.withMemoryRebound(to: UInt8.self, capacity: Int(entity.pointee.d_reclen)) { pointer -> [UInt8] in
#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
                    [UInt8](UnsafeBufferPointer(start: pointer, count: Int(entity.pointee.d_namlen)))
#elseif os(Linux) || os(Android)
                    [UInt8](UnsafeBufferPointer(start: pointer, count: 256))
#endif
                }
                return String(decoding: buffer, as: UTF8.self)
            }
#else
            let path = String(cString: _platform_shims_dirent_d_name(entity))
#endif
            results.append(path)
        }
        return results.filter({ !(($0 == ".") || ($0 == "..")) })
    }
    /*
    func create() throws {
        let path = path.resolved
        guard !exists(at: path.rawValue) else { return }
        
        var parent = path
        parent.components.removeLast()
        if !exists(at: parent.rawValue) {
            try parent.directory.create()
        }
        
        guard mkdir(path.rawValue, S_IRWXU | S_IRWXG | S_IRWXO) == 0 else {
            throw Errno()
        }
    }
    */
}
/*
extension Path {
    func removing(last count: Int) {
    
    }
}
*/
