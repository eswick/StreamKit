#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

public enum FileAccess {
    case ReadOnly
    case ReadWrite
    case WriteOnly
}

public enum FileMode {
    case Append
    case Create
    case CreateNew
    case Open
    case OpenOrCreate
    case Truncate
}

public struct FilePermissions: OptionSetType {
    public static let Read = FilePermissions(read: true)
    public static let Write = FilePermissions(write: true)
    public static let Execute = FilePermissions(execute: true)
    
    public var read: Bool = false
    public var write: Bool = false
    public var execute: Bool = false
    
    public var rawValue: UInt8 {
        get {
            var val: UInt8 = 0
            if read {
                val |= 1
            }
            if write {
                val |= 2
            }
            if execute {
                val |= 4
            }
            return val
        }
        set {
            if newValue & 1 == 1 {
                read = true
            }
            if newValue & 2 == 2 {
                write = true
            }
            if newValue & 4 == 4 {
                execute = true
            }
        }
    }
    
    public init(read: Bool = false, write: Bool = false, execute: Bool = false) {
        self.read = read
        self.write = write
        self.execute = execute
    }
    
    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
}

public func == (left: FilePermissions, right: FilePermissions) -> Bool {
    return left.rawValue == right.rawValue
}

public struct FileFlags {
    private(set) var userPermissions: FilePermissions = FilePermissions()
    private(set) var groupPermissions: FilePermissions = FilePermissions()
    private(set) var otherPermissions: FilePermissions = FilePermissions()
    private(set) var setuid: Bool = false
    private(set) var setgid: Bool = false
    private(set) var sticky: Bool = false
    
    #if os(Linux)
        typealias fileflags_t = UInt32
    #else
        typealias fileflags_t = UInt16
    #endif
    
    private(set) var rawValue: fileflags_t {
        get {
            var val: fileflags_t = 0
            if userPermissions.read {
                val |= S_IRUSR
            }
            if userPermissions.write {
                val |= S_IWUSR
            }
            if userPermissions.execute {
                val |= S_IXUSR
            }
            if groupPermissions.read {
                val |= S_IRGRP
            }
            if groupPermissions.write {
                val |= S_IWGRP
            }
            if groupPermissions.execute {
                val |= S_IXGRP
            }
            if otherPermissions.read {
                val |= S_IROTH
            }
            if otherPermissions.write {
                val |= S_IWOTH
            }
            if otherPermissions.execute {
                val |= S_IXOTH
            }
            if setuid {
                val |= S_ISUID
            }
            if setgid {
                val |= S_ISGID
            }
            if sticky {
                val |= S_ISVTX
            }
            return val
        }
        set {
            userPermissions.read = (newValue & S_IRUSR == S_IRUSR)
            userPermissions.write = (newValue & S_IWUSR == S_IWUSR)
            userPermissions.execute = (newValue & S_IXUSR == S_IXUSR)
            
            groupPermissions.read = (newValue & S_IRGRP == S_IRGRP)
            groupPermissions.write = (newValue & S_IWGRP == S_IWGRP)
            groupPermissions.execute = (newValue & S_IXGRP == S_IXGRP)
            
            otherPermissions.read = (newValue & S_IROTH == S_IROTH)
            otherPermissions.write = (newValue & S_IWOTH == S_IWOTH)
            otherPermissions.execute = (newValue & S_IXOTH == S_IXOTH)

            setuid = (newValue & S_ISUID == S_ISUID)
            setgid = (newValue & S_ISGID == S_ISGID)
            sticky = (newValue & S_ISVTX == S_ISVTX)
        }
    }
    
    var octalRepresentation: String {
        get {
            return String(self.rawValue, radix: 8)
        }
    }
    
    init(rawValue: fileflags_t) {
        self.rawValue = rawValue
    }
    
    init?(octalRepresentation rep: String) {
        if rep.characters.count == 3 {
            var str = "0"
            str.appendContentsOf(rep)
            if let val = fileflags_t(str, radix: 8) {
                self.rawValue = val
            } else {
                return nil
            }
        } else if rep.characters.count == 4 {
            if let val = fileflags_t(rep, radix: 8) {
                self.rawValue = val
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    init?(octalRepresentation rep: UInt) {
        let strRep = String(rep)
        self.init(octalRepresentation: strRep)
    }
    
    init() {
        self.rawValue = 0
    }
}

public func == (left: FileFlags, right: FileFlags) -> Bool {
    return left.rawValue == right.rawValue
}

public enum FileStreamError: ErrorType {
    case OpenFailed(Int32)
    case InvalidArgument(String)
    case FileNotFound
    case FileExists
}

private func fileExists(path: String) -> Bool {
    #if os(Linux)
        return Glibc.access(path, F_OK) != -1
    #else
        return Darwin.access(path, F_OK) != -1
    #endif
}

private func fileIsReadable(path: String) -> Bool {
    #if os(Linux)
        return Glibc.access(path, R_OK) != -1
    #else
        return Darwin.access(path, R_OK) != -1
    #endif
}

private func fileIsWritable(path: String) -> Bool {
    #if os(Linux)
        return Glibc.access(path, W_OK) != -1
    #else
        return Darwin.access(path, W_OK) != -1
    #endif
}

class FileStream: IOStream {
    
    let path: String
    let mode: FileMode
    let access: FileAccess
    
    init(path: String, mode: FileMode = .OpenOrCreate, access: FileAccess = .ReadWrite, creationFlags: FileFlags = FileFlags(rawValue: 0o644)) throws {
        self.path = path
        self.mode = mode
        self.access = access
        
        var readable = false
        var writable = false
        
        var flags: Int32
        
        switch access {
        case .ReadOnly:
            flags = O_RDONLY
            readable = true
            break
        case .WriteOnly:
            flags = O_WRONLY
            writable = true
            break
        case .ReadWrite:
            flags = O_RDWR
            readable = true
            writable = true
            break
        }
        
        switch mode {
        case .Append:
            if readable {
                throw FileStreamError.InvalidArgument("Read access not allowed with FileMode.Append")
            }
            if !fileExists(path) {
                throw FileStreamError.FileNotFound
            }
            flags |= O_APPEND
            break
        case .Create:
            if !writable {
                throw FileStreamError.InvalidArgument("Write access required with FileMode.Create")
            }
            if !fileExists(path) {
                flags |= O_CREAT
            } else {
                flags |= O_TRUNC
            }
            break
        case .CreateNew:
            if fileExists(path) {
                throw FileStreamError.FileExists
            }
            flags |= O_CREAT
            break
        case .Open:
            if !fileExists(path) {
                throw FileStreamError.FileNotFound
            }
            break
        case .OpenOrCreate:
            if !fileExists(path) {
                flags |= O_CREAT
            }
            break
        case .Truncate:
            if !fileExists(path) {
                throw FileStreamError.FileNotFound
            }
            flags |= O_TRUNC
            break
        }
        
        let openResult = open(path, flags, creationFlags.rawValue)
        
        if openResult == -1 {
            throw FileStreamError.OpenFailed(errno)
        }
        
        super.init(fileDescriptor: openResult, canRead: readable, canWrite: writable, canTimeout: false, canSeek: true)
    }
}