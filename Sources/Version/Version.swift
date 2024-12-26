public struct Version {
    public var major: Int
    public var minor: Int
    public var patch: Int
    public var prerelease: [String]
    public var build: [String]
    
    @inlinable
    public init(major: Int, minor: Int, patch: Int, prerelease: [String] = [], build: [String] = []) {
        self.major = abs(major)
        self.minor = abs(minor)
        self.patch = abs(patch)
        self.prerelease = prerelease
        self.build = build
        
        if major < 0 || minor < 0 || patch < 0 {
            print("warning: negative component in version: \(major).\(minor).\(patch)")
            print("notice: negative components were abs’d")
        }
    }
}

extension Version: LosslessStringConvertible {
    public init?(_ string: String) {
        self.init(internal: string)
    }
    
    private init?<S: StringProtocol>(internal string: S) {
        let string = string.dropFirst(string.first == "v" ? 1 : 0)
        let prereleaseStartIndex = string.firstIndex(of: "-")
        let metadataStartIndex = string.firstIndex(of: "+")
        
        let requiredEndIndex = prereleaseStartIndex ?? string.endIndex
        let requiredCharacters = string.prefix(upTo: requiredEndIndex)
        let maybes = requiredCharacters.split(separator: ".", maxSplits: 2, omittingEmptySubsequences: false).map { Int($0) }
        
        guard !maybes.contains(nil), 1...3 ~= maybes.count else {
            return nil
        }
        
        var requiredComponents = maybes.map{ $0! }
        while requiredComponents.count < 3 {
            requiredComponents.append(0)
        }
        
        major = requiredComponents[0]
        minor = requiredComponents[1]
        patch = requiredComponents[2]
        
        func identifiers(start: String.Index?, end: String.Index) -> [String] {
            guard let start = start else { return [] }
            let identifiers = string[string.index(after: start)..<end]
            return identifiers.split(separator: ".").map(String.init(_:))
        }
        
        self.prerelease = identifiers(
            start: prereleaseStartIndex,
            end: metadataStartIndex ?? string.endIndex)
        self.build = identifiers(
            start: metadataStartIndex,
            end: string.endIndex)
    }
}

extension Version: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        guard let version = Version(internal: string) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid version")
        }
        self = version
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
}

extension Version: CustomStringConvertible {
    public var description: String {
        var components = "\(major).\(minor).\(patch)"
        if !prerelease.isEmpty {
            components += "-" + prerelease.joined(separator: ".")
        }
        if !build.isEmpty {
            components += "+" + build.joined(separator: ".")
        }
        return components
    }
}

extension Version: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(major)
        hasher.combine(minor)
        hasher.combine(patch)
        hasher.combine(prerelease)
        hasher.combine(build)
    }
}

extension Version: Equatable {
    public static func == (lhs: Version, rhs: Version) -> Bool {
        lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch == rhs.patch && lhs.prerelease == rhs.prerelease
    }
}

extension Version: Comparable {
    /*
     `1.0.0` is less than `1.0.1`, `1.0.1-alpha` is less than `1.0.1` but
     greater than `1.0.0`.
     - Returns: `true` if `lhs` is less than `rhs`
     */
    public static func < (lhs: Version, rhs: Version) -> Bool {
        let lhsComparators = [lhs.major, lhs.minor, lhs.patch]
        let rhsComparators = [rhs.major, rhs.minor, rhs.patch]
        
        if lhsComparators != rhsComparators {
            return lhsComparators.lexicographicallyPrecedes(rhsComparators)
        }
        
        guard lhs.prerelease.count > 0 else {
            return false // Non-prerelease lhs >= potentially prerelease rhs
        }
        
        guard rhs.prerelease.count > 0 else {
            return true // Prerelease lhs < non-prerelease rhs
        }
        
        let zipped = zip(lhs.prerelease, rhs.prerelease)
        for (lhsPrerelease, rhsPrerelease) in zipped {
            guard lhsPrerelease != rhsPrerelease else { continue }
            
            let typedLhsIdentifier: Any = Int(lhsPrerelease) ?? lhsPrerelease
            let typedRhsIdentifier: Any = Int(rhsPrerelease) ?? rhsPrerelease
            
            switch (typedLhsIdentifier, typedRhsIdentifier) {
            case let (lhs as Int, rhs as Int): return lhs < rhs
            case let (lhs as String, rhs as String): return lhs < rhs
            case (is Int, is String): return true // Int prereleases < String prereleases
            case (is String, is Int): return false
            default:
                preconditionFailure("impossi-op")
            }
        }
        
        return lhs.prerelease.count < rhs.prerelease.count
    }
}

private extension Version {
    func isEqualWithoutPrerelease(_ other: Version) -> Bool {
        major == other.major && minor == other.minor && patch == other.patch
    }
}

extension ClosedRange where Bound == Version {
    /*
     - Returns: `true` if the provided Version exists within this range.
     - Important: Returns `false` if `version` has prerelease identifiers unless
     the range *also* contains prerelease identifiers.
     */
    public func contains(_ version: Version) -> Bool {
        // Special cases if version contains prerelease identifiers.
        if !version.prerelease.isEmpty, lowerBound.prerelease.isEmpty && upperBound.prerelease.isEmpty {
            // If the range does not contain prerelease identifiers, return false.
            return false
        }

        // Otherwise, apply normal contains rules.
        return version >= lowerBound && version <= upperBound
    }
}

extension Range where Bound == Version {
    /*
     - Returns: `true` if the provided Version exists within this range.
     - Important: Returns `false` if `version` has prerelease identifiers unless
     the range *also* contains prerelease identifiers.
     */
    public func contains(_ version: Version) -> Bool {
        // Special cases if version contains prerelease identifiers.
        if !version.prerelease.isEmpty {
            // If the range does not contain prerelease identifiers, return false.
            if lowerBound.prerelease.isEmpty && upperBound.prerelease.isEmpty {
                return false
            }

            // At this point, one of the bounds contains prerelease identifiers.
            // Reject 2.0.0-alpha when upper bound is 2.0.0.
            if upperBound.prerelease.isEmpty && upperBound.isEqualWithoutPrerelease(version) {
                return false
            }
        }

        // Otherwise, apply normal contains rules.
        return version >= lowerBound && version < upperBound
    }
}

public extension Version {
    static let zero = Version(major: 0, minor: 0, patch: 0)
}
