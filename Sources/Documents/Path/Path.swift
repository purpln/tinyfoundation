import LibC

public struct Path {
    public internal(set) var rawValue: String
    
    public init(_ path: String = Path.dot, expanding: Bool = false) {
        if expanding {
            self = Path(path).expanded
        } else {
            rawValue = path
        }
    }
    
    internal var safeRawValue: String {
        rawValue.isEmpty ? Path.dot : rawValue
    }
}

internal extension Path {
    @usableFromInline
    static let separator = "/"
    @usableFromInline
    static let dot = "."
    @usableFromInline
    static let tilde = "~"
}

public extension Path {
    static let root = Path(separator)
    static let home = Path(Path.tilde, expanding: true)
    
    static var application: Path {
        Path(getExecutablePath()!)
    }
    
    static var documents: Path {
        Path(getDocumentsPath()!)
    }
    
    static var current: Path {
        get {
            let current = getCurrentDirectory()
            return Path(current)
        }
        set {
            do {
                try setCurrentDirectory(newValue.absolute.safeRawValue)
            } catch {
                preconditionFailure("\(error) - \(newValue.rawValue)")
            }
        }
    }
}

public extension Path {
    var absolute: Path {
        isAbsolute ? resolved : expanded.resolved
    }
    /*
    var relative: Path {
        isRelative ? resolved : (self - Path.current).resolved
    }
    */
    var resolved: Path {
        guard !rawValue.isEmpty, rawValue != Path.dot, rawValue != Path.separator else { return self }
        var components = expanded.components
        
        var i: Int = 0
        repeat {
            let component = components[i]
            if component == ".." {
                if i - 1 > -1 {
                    components.remove(at: i)
                    components.remove(at: i - 1)
                    i -= 1
                } else {
                    return self
                }
            } else if component == "." {
                components.remove(at: i)
            } else {
                i += 1
            }
        } while i != components.count
        
        return Path(components, absolute: true)
    }
    
    var expanded: Path {
        if rawValue.hasPrefix(Path.tilde) {
            var path = rawValue
            var user: String?
            path.remove(at: path.startIndex)
            if !path.isEmpty, !path.hasPrefix(Path.separator) {
                let start = path.startIndex
                let end = path.endIndex
                let index = path.firstIndex(of: Character(Path.separator)) ?? end
                user = String(path[start..<index])
                path = String(path[index..<end])
            }
            let home = getHomeDirectory(for: user)!
            return Path(home + path)
        } else if isRelative {
            return Path.current + self
        } else {
            return self
        }
    }
}

public extension Path {
    var isAbsolute: Bool {
        rawValue.hasPrefix(Path.separator)
    }
    
    var isRelative: Bool {
        !isAbsolute
    }
    
    var isRoot: Bool {
        resolved.rawValue == Path.separator
    }
    
    var isEmpty: Bool {
        rawValue.isEmpty || rawValue == Path.dot
    }
}

public extension Path {
    var document: Document {
        Document(path: self)
    }
    
    var directory: Directory {
        Directory(path: self)
    }
}

import LibC

public extension Path {
    enum Kind {
        case file, symlink, directory
    }
    
    var kind: Kind? {
        guard let info = attributes(at: resolved.rawValue) else { return nil }
        if info.st_mode & S_IFMT == S_IFLNK {
            return .symlink
        } else if info.st_mode & S_IFMT == S_IFDIR {
            return .directory
        } else {
            return .file
        }
    }
    
    var exists: Bool {
        Documents.exists(at: resolved.rawValue)
    }
}

internal func attributes(at path: String) -> stat? {
    var buffer = stat()
    guard lstat(path, &buffer) == 0 else {
        return nil
    }
    return buffer
}

internal func exists(at path: String) -> Bool {
    var s = stat()
    if lstat(path, &s) >= 0 {
        // don't chase the link for this magic case -- we might be /Net/foo
        // which is a symlink to /private/Net/foo which is not yet mounted...
        if (s.st_mode & S_IFMT) == S_IFLNK {
            if (s.st_mode & S_ISVTX) == S_ISVTX {
                return true
            }
            // chase the link; too bad if it is a slink to /Net/foo
            stat(path, &s)
        }
    } else {
        return false
    }
    return true
}
