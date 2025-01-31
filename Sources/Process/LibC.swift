import LibC

public extension Process {
    static func spawn(arguments: [String], environment: [String], actions array: [Action]) throws -> Process {
        let argv = arguments.map { strdup($0) }
        defer {
            argv.forEach { free($0) }
        }
        
        let env = environment.map { strdup($0) }
        defer {
            env.forEach { free($0) }
        }
        
#if canImport(Darwin.C) || canImport(Android)
        var attr: posix_spawnattr_t? = nil
#elseif canImport(Glibc) || canImport(Musl)
        var attr: posix_spawnattr_t = posix_spawnattr_t()
#endif
        try nothingOrErrno(retryOnInterrupt: false, {
            posix_spawnattr_init(&attr)
        }).get()
        defer {
            posix_spawnattr_destroy(&attr)
        }
        
#if canImport(Darwin.C) || canImport(Android)
        var actions: posix_spawn_file_actions_t? = nil
#elseif canImport(Glibc) || canImport(Musl)
        var actions: posix_spawn_file_actions_t = posix_spawn_file_actions_t()
#endif
        try nothingOrErrno(retryOnInterrupt: false, {
            posix_spawn_file_actions_init(&actions)
        }).get()
        defer {
            posix_spawn_file_actions_destroy(&actions)
        }
        
        for action in array {
            switch action {
            case .open(let descriptor, let path, let oflag, let mode):
                let path = strdup(path)
                defer { free(path) }
                try nothingOrErrno(retryOnInterrupt: false, {
                    posix_spawn_file_actions_addopen(&actions, descriptor.rawValue, path!, oflag, mode)
                }).get()
            case .close(let descriptor):
                try nothingOrErrno(retryOnInterrupt: false, {
                    posix_spawn_file_actions_addclose(&actions, descriptor.rawValue)
                }).get()
            case .connect(let descriptor, let new):
                try nothingOrErrno(retryOnInterrupt: false, {
                    posix_spawn_file_actions_adddup2(&actions, descriptor.rawValue, new.rawValue)
                }).get()
            }
        }
        
        var pid = pid_t()
        try nothingOrErrno(retryOnInterrupt: false, {
            posix_spawnp(&pid, arguments[0], &actions, &attr, argv + [nil], env + [nil])
        }).get()
        
        return Process(pid: pid)
    }
}
