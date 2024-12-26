import LibC

func pipe() throws -> (from: IO, to: IO) {
    var pipes: (from: CInt, to: CInt) = (0, 0)
    guard pipe(&pipes.from) == 0 else {
        throw Errno()
    }
    let input = FileDescriptor(rawValue: pipes.from)!
    let output = FileDescriptor(rawValue: pipes.to)!
    return (IO(descriptor: input), IO(descriptor: output))
}

extension Process {
    static func spawn(arguments: [String], environment: [String], actions array: [Action]) throws -> Process {
        let argv = arguments.map { strdup($0) }
        defer { argv.forEach { free($0) } }
        
        let env = environment.map { strdup($0) }
        defer { env.forEach { free($0) } }
        
#if canImport(Darwin.C) || canImport(Android)
        var attributes: posix_spawnattr_t? = nil
#elseif canImport(Glibc) || canImport(Musl)
        var attributes: posix_spawnattr_t = posix_spawnattr_t()
#endif
        posix_spawnattr_init(&attributes)
        defer { posix_spawnattr_destroy(&attributes) }
        
#if canImport(Darwin.C) || canImport(Android)
        var actions: posix_spawn_file_actions_t? = nil
#elseif canImport(Glibc) || canImport(Musl)
        var actions: posix_spawn_file_actions_t = posix_spawn_file_actions_t()
#endif
        posix_spawn_file_actions_init(&actions)
        defer { posix_spawn_file_actions_destroy(&actions) }
        
        for action in array {
            switch action {
            case .open(let descriptor, let path, let oflag, let mode):
                let path = strdup(path)
                defer { free(path) }
                posix_spawn_file_actions_addopen(&actions, descriptor.rawValue, path!, oflag, mode)
            case .close(let descriptor):
                posix_spawn_file_actions_addclose(&actions, descriptor.rawValue)
            case .connect(let descriptor, let new):
                posix_spawn_file_actions_adddup2(&actions, descriptor.rawValue, new.rawValue)
            }
        }
        
        var pid = pid_t()
        let result = posix_spawnp(&pid, arguments[0], &actions, &attributes, argv + [nil], env + [nil])
        guard result == 0 else { throw Errno(rawValue: result) }
        
        return Process(pid: pid)
    }
}
