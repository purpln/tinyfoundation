public func + (lhs: Path, rhs: Path) -> Path {
    if lhs.rawValue.isEmpty || lhs.rawValue == "." { return rhs }
    if rhs.rawValue.isEmpty || rhs.rawValue == "." { return lhs }
    switch (lhs.rawValue.hasSuffix(Path.separator), rhs.rawValue.hasPrefix(Path.separator)) {
    case (true, true):
        let rhsRawValue = rhs.rawValue.dropFirst()
        return Path("\(lhs.rawValue)\(rhsRawValue)")
    case (false, false):
        return Path("\(lhs.rawValue)\(Path.separator)\(rhs.rawValue)")
    default:
        return Path("\(lhs.rawValue)\(rhs.rawValue)")
    }
}
/*
public func - (lhs: Path, rhs: Path) -> Path {
    guard !lhs.rawValue.isEmpty || lhs.rawValue != "." else { return rhs }
    guard !rhs.rawValue.isEmpty || rhs.rawValue != "." else { return lhs }
    guard let range = lhs.rawValue.ranges(of: rhs.rawValue).first else { return lhs }
    var path = lhs.rawValue
    path.removeSubrange(range)
    if range.lowerBound == lhs.rawValue.startIndex, path.hasPrefix(Path.separator) {
        path.removeFirst()
    }
    if range.upperBound == lhs.rawValue.endIndex, path.hasSuffix(Path.separator) {
        path.removeLast()
    }
    return Path(path)
}
*/
