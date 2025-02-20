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
        try getDirectoryContents(path.resolved.rawValue)
            .filter({ !(($0 == ".") || ($0 == "..")) })
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
