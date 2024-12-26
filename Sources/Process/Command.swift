import Documents
import LibC

public func process(command: String, arguments: String..., environment: [String: String] = [:], path: String? = nil) throws {
    try process(command: command, arguments: Array(arguments), environment: environment, path: path)
}

public func process(command: String, arguments: [String] = [], environment: [String: String] = [:], path: String? = nil) throws {
    let result = try result(command: command, arguments: Array(arguments), environment: environment, path: path)
    guard !result.isEmpty else { return }
    print(result)
}

public func result(command: String, arguments: String..., environment: [String: String] = [:], path: String? = nil) throws -> String {
    try result(command: command, arguments: Array(arguments), environment: environment, path: path)
}

public func result(command: String, arguments: [String] = [], environment: [String: String] = [:], path: String? = nil) throws -> String {
    if let path = path {
        Path.current = Path(path).absolute
    }
    
    let environment = standart(environment: environment)
    
    let output = try pipe()
    let error = try pipe()
    
    let actions: [Process.Action] = [
        .close(output.from.descriptor),
        .close(error.from.descriptor),
        .connect(output.to.descriptor, .output),
        .connect(error.to.descriptor, .error),
        .close(output.to.descriptor),
        .close(error.to.descriptor),
    ]
    
    let process = try Process.spawn(arguments: [command] + arguments, environment: environment, actions: actions)
    
    try output.to.close()
    try error.to.close()
    
    let result = try process.wait()
    
    let logs = try output.from.read()
    let fault = try error.from.read()
    
    guard result == .success else {
        print(logs)
        throw ProcessError(code: result.exit, description: fault)
    }
    
    return logs
}

internal func standart(environment values: [String: String]) -> [String] {
    environment.merging(values) { current, new in current }
        .reduce(into: [String]()) { array, element in
            array.append("\(element.key)=\(element.value)")
        }
}
