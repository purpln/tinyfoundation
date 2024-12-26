import LibC

struct IO {
    let descriptor: FileDescriptor
}

extension IO {
    func read() throws -> String {
        var buffer = [UInt8]()
        let length = 1024
        while let chunk = try chunk(descriptor: descriptor, length: length) {
            buffer.append(contentsOf: chunk)
            guard chunk.count < length else { continue }
            break
        }
        try close()
        
        var string = String(cString: buffer + [0])
        
        if !string.isEmpty {
            string.removeLast()
        }
        
        return string
    }
    
    func close() throws {
        try stop(descriptor: descriptor)
    }
}

private func chunk(descriptor: FileDescriptor, length: Int) throws -> [UInt8]? {
    var buf = [UInt8](repeating: 0, count: length)
    return try retryInterrupt {
        let n = read(descriptor.rawValue, &buf, length)
        switch n {
        case -1:
            throw Errno()
        case 0:
            return nil
        default:
            return Array(buf[0..<n])
        }
    }
}

private func stop(descriptor: FileDescriptor) throws {
    let rv = close(descriptor.rawValue)
    guard rv == 0 else {
        throw Errno()
    }
}
