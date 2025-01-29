import LibC

public struct IO {
    public let descriptor: FileDescriptor
    
    public init(descriptor: FileDescriptor) {
        self.descriptor = descriptor
    }
}

public extension IO {
    func read(stream: Bool) throws -> String {
        var buffer = [UInt8]()
        let length = 1024
        while true {
            let chunk = try chunk(descriptor: descriptor, length: length)
            guard !chunk.isEmpty else { break }
            
            if stream {
                print(String(decoding: chunk, as: UTF8.self), terminator: "")
            } else {
                buffer.append(contentsOf: chunk)
            }
        }
        
        return buffer.trimming.string
    }
    
    func close() throws {
        try stop(descriptor: descriptor)
    }
}

private func chunk(descriptor: FileDescriptor, length: Int) throws -> [UInt8] {
    try [UInt8](unsafeUninitializedCapacity: length) { buffer, count in
        try retryInterrupt {
            let result = read(descriptor.rawValue, buffer.baseAddress, length)
            switch result {
            case -1:
                throw Errno()
            default:
                count = result
            }
        }
    }
}

private func stop(descriptor: FileDescriptor) throws {
    guard close(descriptor.rawValue) == 0 else { throw Errno() }
}

public extension Array where Element == UInt8 {
    var trimming: [UInt8] {
        guard !isEmpty else { return self }
        return dropLast()
    }
    
    var string: String {
        String(decoding: self, as: UTF8.self)
    }
}
