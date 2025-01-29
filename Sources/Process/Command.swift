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
    
    let output = try pipe()
    let error = try pipe()
    
    let actions: [Process.Action] = [
        //.open(.input, "/dev/null", O_RDONLY, 0),
        .connect(output.to.descriptor, .output),
        .connect(error.to.descriptor, .error),
        .close(output.from.descriptor),
        .close(error.from.descriptor),
    ]
    
    let process = try Process.spawn(arguments: [command] + arguments, environment: environment, actions: actions)
    
    try output.to.close()
    try error.to.close()
    
    let logs = try output.from.read(stream: stream)
    let fault = try error.from.read(stream: false)
    
    try output.from.close()
    try error.from.close()
    
    let status = try process.wait()
    
    guard status == .success else {
        if !logs.isEmpty {
            print(logs)
        }
        print(command, arguments.joined(separator: " "), path ?? "")
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
