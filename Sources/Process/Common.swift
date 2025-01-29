public func shell(command: String, arguments: String..., environment: [String: String] = [:], path: String? = nil) throws {
    try shell(command: command, arguments: arguments, environment: environment, path: path)
}

public func shell(command: String, arguments: [String] = [], environment: [String: String] = [:], path: String? = nil) throws {
    let arguments = arguments.isEmpty ? "" : " " + arguments.joined(separator: " ")
    try process(command: "sh", arguments: "-c", command + arguments, environment: environment, path: path)
}

@_disfavoredOverload
public func shell(command: String, arguments: String..., environment: [String: String] = [:], path: String? = nil) throws -> String {
    try shell(command: command, arguments: arguments, environment: environment, path: path)
}

@_disfavoredOverload
public func shell(command: String, arguments: [String] = [], environment: [String: String] = [:], path: String? = nil) throws -> String {
    let arguments = arguments.isEmpty ? "" : " " + arguments.joined(separator: " ")
    return try result(command: "sh", arguments: "-c", command + arguments, environment: environment, path: path)
}

public func sudo(password: String, command: String, arguments: String..., environment: [String: String] = [:], path: String? = nil) throws {
    try sudo(password: password, command: command, arguments: arguments, environment: environment, path: path)
}

public func sudo(password: String, command: String, arguments: [String] = [], environment: [String: String] = [:], path: String? = nil) throws {
    try shell(command: "echo", arguments: [password, "|", "sudo", "-S", command] + arguments, environment: environment, path: path)
}

public func sudo(password: String, command: String, arguments: String..., environment: [String: String] = [:], path: String? = nil) throws -> String {
    try sudo(password: password, command: command, arguments: arguments, environment: environment, path: path)
}

@_disfavoredOverload
public func sudo(password: String, command: String, arguments: [String] = [], environment: [String: String] = [:], path: String? = nil) throws -> String {
    try shell(command: "echo", arguments: [password, "|", "sudo", "-S", command] + arguments, environment: environment, path: path)
}

public func plutil(arguments: String..., at path: String) throws -> String {
    try plutil(arguments: arguments, at: path)
}

public func plutil(arguments: [String], at path: String) throws -> String {
    try result(command: "plutil", arguments: arguments, path: path)
}

public func remove(_ component: String, at path: String? = nil) throws {
    try process(command: "rm", arguments: "-rf", component, path: path)
}

public func copy(from: String, to: String, at path: String? = nil) throws {
    try process(command: "cp", arguments: "-r", from, to, path: path)
}

public func find(query: String, at path: String? = nil) throws -> String {
    try result(command: "find", arguments: ".", "-name", query, path: path)
}

public func list(at path: String? = nil) throws -> [String] {
    try result(command: "ls", arguments: "-a", ".", path: path).split(separator: "\n").map(String.init)
}

public func view(document: String, at path: String? = nil) throws -> String {
    try result(command: "cat", arguments: document, path: path)
}

public func create(directory: String, at path: String? = nil) throws {
    try process(command: "mkdir", arguments: "-p", directory, path: path)
}

public func zip(_ archive: String, name: String, at path: String? = nil) throws {
    try process(command: "zip", arguments: "--symlinks", name, "-r", archive, path: path)
}

public func unzip(_ archive: String, to: String = ".", at path: String? = nil) throws {
    try process(command: "unzip", arguments: "-o", archive, "-d", to, path: path)
}

public func symbolic(target: String, link: String, at path: String? = nil) throws {
    try process(command: "ln", arguments: "-s", target, link, path: path)
}
