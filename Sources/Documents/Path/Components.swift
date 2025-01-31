public extension Path {
    init(_ components: [Component], absolute: Bool = false) {
        let prefix = absolute ? Path.separator : ""
        self.rawValue = prefix + components.map(\.rawValue).joined(separator: Path.separator)
    }
    
    var components: [Component] {
        get {
            guard !rawValue.isEmpty, rawValue != Path.dot else { return [] }
            
            var result = [String]()
            var index = rawValue.startIndex
            let end = rawValue.endIndex
            
            while index < end {
                while index < end && rawValue[index] == Character(Path.separator) {
                    index = rawValue.index(after: index)
                }
                guard index != end else { break }
                
                var current = index
                while current < end && rawValue[current] != Character(Path.separator) {
                    current = rawValue.index(after: current)
                }
                result.append(String(rawValue[index..<current]))
                index = current
            }
            
            return result.map(Component.init)
        }
        set {
            let prefix = rawValue.hasPrefix(Path.separator) ? Path.separator : ""
            rawValue = prefix + newValue.map(String.init).joined(separator: Path.separator)
        }
    }
}

public extension Path {
    struct Component: RawRepresentable, ExpressibleByStringLiteral, CustomStringConvertible {
        public var rawValue: String
        
        @_disfavoredOverload
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(stringLiteral rawValue: StringLiteralType) {
            self.rawValue = rawValue
        }
        
        public var description: String {
            rawValue
        }
    }
}
