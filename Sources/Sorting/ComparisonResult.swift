/// Used to indicate how items in a request are ordered, from the first one given in a method invocation or function call to the last (that is, left to right in code).
/// Given the function:
/// ```
/// func f(a: Int, b: Int) -> ComparisonResult
/// ```
/// If:
///   `a < b`   then return `.orderedAscending`. The left operand is smaller than the right operand.
///   `a > b`   then return `.orderedDescending`. The left operand is greater than the right operand.
///   `a == b`  then return `.orderedSame`. The operands are equal.
@frozen
public enum ComparisonResult: Int, Sendable {
    case orderedAscending   = -1
    case orderedSame        = 0
    case orderedDescending  = 1
}

extension ComparisonResult: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let intValue = try container.decode(Int.self)
        guard let value = ComparisonResult(rawValue: intValue) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot initialize ComparisonResult with invalid value of '\(intValue)'")
        }
        self = value
    }
}
