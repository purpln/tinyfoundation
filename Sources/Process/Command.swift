import LibC

public func process(command: String, arguments: String..., environment: [String: String] = [:], path: String? = nil) throws {
    try process(command: command, arguments: Array(arguments), environment: environment, path: path)
}

public func process(command: String, arguments: [String] = [], environment: [String: String] = [:], path: String? = nil) throws {
    try result(command: command, arguments: arguments, environment: environment, path: path, stream: true)
}

public func result(command: String, arguments: String..., environment: [String: String] = [:], path: String? = nil) throws -> String {
    try result(command: command, arguments: Array(arguments), environment: environment, path: path)
}

@discardableResult
public func result(command: String, arguments: [String] = [], environment: [String: String] = [:], path: String? = nil, stream: Bool = false) throws -> String {
    if let path = path {
        try setCurrentDirectory(path)
    }
    
    let environment = standart(environment: environment)
    
    let output = try FileDescriptor.pipe()
    let error = try FileDescriptor.pipe()
    
    let actions: [Process.Action] = [
        //.open(.input, "/dev/null", O_RDONLY, 0),
        .connect(output.write, .output),
        .connect(error.write, .error),
        .close(output.read),
        .close(error.read),
    ]
    
    let process = try Process.spawn(arguments: [command] + arguments, environment: environment, actions: actions)
    
    try output.write.close()
    try error.write.close()
    
    let logs = try output.read.read(stream: stream)
    let fault = try error.read.read(stream: false)
    
    try output.read.close()
    try error.read.close()
    
    let status = try process.wait()
    
    guard status == .success else {
        if !logs.isEmpty {
            print(logs)
        }
        throw ProcessError(code: status.exit, description: fault)
    }
    
    return logs
}

private func standart(environment values: [String: String]) -> [String] {
    environment.merging(values) { current, new in current }
        .reduce(into: [String]()) { result, element in
            result.append("\(element.key)=\(element.value)")
        }
}

extension FileDescriptor {
    func read(stream: Bool) throws -> String {
        var buffer = [UInt8]()
        let length = 1024
        while true {
            let chunk = try [UInt8](unsafeUninitializedCapacity: length) { buffer, count in
                count = try read(into: UnsafeMutableRawBufferPointer(buffer), retryOnInterrupt: true)
            }
            guard !chunk.isEmpty else { break }
            
            if stream {
                print(String(decoding: chunk, as: UTF8.self), terminator: "")
            } else {
                buffer.append(contentsOf: chunk)
            }
        }
        
        return buffer.trimming.string
    }
}

extension Array where Element == UInt8 {
    var trimming: [UInt8] {
        guard !isEmpty else { return self }
        return dropLast()
    }
    
    var string: String {
        String(decoding: self, as: UTF8.self)
    }
}
