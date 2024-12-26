public func remove(_ component: String, at path: String? = nil) throws {
    try process(command: "rm", arguments: "-rf", component, path: path)
}

public func copy(from: String, to: String, at path: String? = nil) throws {
    try process(command: "cp", arguments: "-r", from, to, path: path)
}

public func find(query: String, at path: String? = nil) throws -> String {
    try result(command: "find", arguments: ".", "-name", query, path: path)
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
