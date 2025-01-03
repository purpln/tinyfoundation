public var environment: [String: String] {
    let equal: Character = "="
    var result = [String: String]()
    var i = 0
    
    while let entry = pointer[i] {
        defer { i += 1 }
        
        let entry = String(cString: entry)
        guard let index = entry.firstIndex(of: equal) else { continue }
        
        let key = String(entry.prefix(upTo: index))
        let value = String(entry.suffix(from: index).dropFirst())
        
        result[key] = value
    }
    return result
}

private var pointer: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?> {
#if os(Android)
    environ!
#else
    environ
#endif
}
