import LibC

#if canImport(Darwin.C)
private typealias Pointer = UnsafeMutablePointer<DIR>
#elseif canImport(Glibc) || canImport(Musl) || canImport(Android)
private typealias Pointer = OpaquePointer
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
        while let ent = readdir(pointer) {
            var name = ent.pointee.d_name
            let path = withUnsafePointer(to: &name) { (ptr) -> String? in
#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
                var buffer = ptr.withMemoryRebound(to: CChar.self, capacity: Int(ent.pointee.d_reclen)) { (ptrc) -> [CChar] in
                    [CChar](UnsafeBufferPointer(start: ptrc, count: Int(ent.pointee.d_namlen)))
                }
                buffer.append(0)
#elseif os(Linux) || os(Android)
                let buffer = ptr.withMemoryRebound(to: CChar.self, capacity: Int(ent.pointee.d_reclen)) { (ptrc) -> [CChar] in
                    [CChar](UnsafeBufferPointer(start: ptrc, count: 256))
                }
#endif
                return String(cString: buffer)
            }
            guard let path else { continue }
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
