import LibC

public struct Directory {
    public var path: Path
    
    private var allocator: Allocator<system_DIRPtr, Errno>
    
    public init(path: Path) {
        self.path = path
        
        let path = path.resolved.rawValue
        allocator = Allocator(open: { () throws(Errno) in
            guard let pointer = opendir(path) else { throw Errno.current }
            return pointer
        }, close: { pointer throws(Errno) in
            try nothingOrErrno(retryOnInterrupt: false, {
                closedir(pointer)
            }).get()
        })
    }
}

public extension Directory {
    func contents() throws -> [String] {
        try getDirectoryContents(path.resolved.rawValue).map(\.name)
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
            throw Errno.current
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
