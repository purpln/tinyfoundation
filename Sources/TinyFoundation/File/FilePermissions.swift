import TinySystem

@frozen
public struct FilePermissions: OptionSet, Equatable, Hashable, Sendable {
    @_alwaysEmitIntoClient
    public let rawValue: PlatformMode
    
    @_alwaysEmitIntoClient
    public init(rawValue: PlatformMode) {
        self.rawValue = rawValue
    }
}

public extension FilePermissions {
    @_alwaysEmitIntoClient
    static var otherRead: FilePermissions {
        FilePermissions(rawValue: 0o4)
    }
    
    @_alwaysEmitIntoClient
    static var otherWrite: FilePermissions {
        FilePermissions(rawValue: 0o2)
    }
    
    @_alwaysEmitIntoClient
    static var otherExecute: FilePermissions {
        FilePermissions(rawValue: 0o1)
    }
    
    @_alwaysEmitIntoClient
    static var otherReadWrite: FilePermissions {
        FilePermissions(rawValue: 0o6)
    }
    
    @_alwaysEmitIntoClient
    static var otherReadExecute: FilePermissions {
        FilePermissions(rawValue: 0o5)
    }
    
    @_alwaysEmitIntoClient
    static var otherWriteExecute: FilePermissions {
        FilePermissions(rawValue: 0o3)
    }
    
    @_alwaysEmitIntoClient
    static var otherReadWriteExecute: FilePermissions {
        FilePermissions(rawValue: 0o7)
    }
    
    @_alwaysEmitIntoClient
    static var groupRead: FilePermissions {
        FilePermissions(rawValue: 0o40)
    }
    
    @_alwaysEmitIntoClient
    static var groupWrite: FilePermissions {
        FilePermissions(rawValue: 0o20)
    }
    
    @_alwaysEmitIntoClient
    static var groupExecute: FilePermissions {
        FilePermissions(rawValue: 0o10)
    }
    
    @_alwaysEmitIntoClient
    static var groupReadWrite: FilePermissions {
        FilePermissions(rawValue: 0o60)
    }
    
    @_alwaysEmitIntoClient
    static var groupReadExecute: FilePermissions {
        FilePermissions(rawValue: 0o50)
    }
    
    @_alwaysEmitIntoClient
    static var groupWriteExecute: FilePermissions {
        FilePermissions(rawValue: 0o30)
    }
    
    @_alwaysEmitIntoClient
    static var groupReadWriteExecute: FilePermissions {
        FilePermissions(rawValue: 0o70)
    }
    
    @_alwaysEmitIntoClient
    static var ownerRead: FilePermissions {
        FilePermissions(rawValue: 0o400)
    }
    
    @_alwaysEmitIntoClient
    static var ownerWrite: FilePermissions {
        FilePermissions(rawValue: 0o200)
    }
    
    @_alwaysEmitIntoClient
    static var ownerExecute: FilePermissions {
        FilePermissions(rawValue: 0o100)
    }
    
    @_alwaysEmitIntoClient
    static var ownerReadWrite: FilePermissions {
        FilePermissions(rawValue: 0o600)
    }
    
    @_alwaysEmitIntoClient
    static var ownerReadExecute: FilePermissions {
        FilePermissions(rawValue: 0o500)
    }
    
    @_alwaysEmitIntoClient
    static var ownerWriteExecute: FilePermissions {
        FilePermissions(rawValue: 0o300)
    }
    
    @_alwaysEmitIntoClient
    static var ownerReadWriteExecute: FilePermissions {
        FilePermissions(rawValue: 0o700)
    }
    
    @_alwaysEmitIntoClient
    static var setUserID: FilePermissions {
        FilePermissions(rawValue: 0o4000)
    }
    
    @_alwaysEmitIntoClient
    static var setGroupID: FilePermissions {
        FilePermissions(rawValue: 0o2000)
    }
    
    @_alwaysEmitIntoClient
    static var saveText: FilePermissions {
        FilePermissions(rawValue: 0o1000)
    }
}

extension FilePermissions: CustomStringConvertible {
    @inline(never)
    public var description: String {
        let descriptions: [(Element, StaticString)] = [
            (.ownerReadWriteExecute, ".ownerReadWriteExecute"),
            (.ownerReadWrite, ".ownerReadWrite"),
            (.ownerReadExecute, ".ownerReadExecute"),
            (.ownerWriteExecute, ".ownerWriteExecute"),
            (.ownerRead, ".ownerRead"),
            (.ownerWrite, ".ownerWrite"),
            (.ownerExecute, ".ownerExecute"),
            (.groupReadWriteExecute, ".groupReadWriteExecute"),
            (.groupReadWrite, ".groupReadWrite"),
            (.groupReadExecute, ".groupReadExecute"),
            (.groupWriteExecute, ".groupWriteExecute"),
            (.groupRead, ".groupRead"),
            (.groupWrite, ".groupWrite"),
            (.groupExecute, ".groupExecute"),
            (.otherReadWriteExecute, ".otherReadWriteExecute"),
            (.otherReadWrite, ".otherReadWrite"),
            (.otherReadExecute, ".otherReadExecute"),
            (.otherWriteExecute, ".otherWriteExecute"),
            (.otherRead, ".otherRead"),
            (.otherWrite, ".otherWrite"),
            (.otherExecute, ".otherExecute"),
            (.setUserID, ".setUserID"),
            (.setGroupID, ".setGroupID"),
            (.saveText, ".saveText")
        ]
        
        return buildDescription(descriptions)
    }
}
