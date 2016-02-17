#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

public let stdout = IOStream(fileDescriptor: STDOUT_FILENO, canRead: false)
public let stdin = IOStream(fileDescriptor: STDIN_FILENO, canWrite: false)
public let stderr = IOStream(fileDescriptor: STDERR_FILENO, canRead: false)

public class IOStream: Stream {
    public let canRead: Bool
    public let canWrite: Bool
    public let canSeek: Bool
    public let canTimeout: Bool
    
    public var position: Int64 {
        get {
            return Int64(lseek(fileDescriptor, 0, SEEK_CUR))
        }
    }
    
    public var readTimeout: UInt = 0
    public var writeTimeout: UInt = 0
    
    public let fileDescriptor: Int32
    
    init(fileDescriptor: Int32, canRead: Bool = true, canWrite: Bool = true, canTimeout: Bool = true, canSeek: Bool = true) {
        self.fileDescriptor = fileDescriptor
        self.canRead = canRead
        self.canWrite = canWrite
        self.canTimeout = canTimeout
        self.canSeek = canSeek
    }
    
    public func read(count: Int64) throws -> [UInt8] {
        if !canRead {
            throw StreamError.ReadFailed(0)
        }
        
        if (readTimeout != 0 && canTimeout) {
            var fds = [pollfd(fd: fileDescriptor, events: Int16(POLLIN), revents: 0)]
            let pollRes = poll(&fds, 1, Int32(readTimeout))
        
            if pollRes == 0 {
                throw StreamError.TimedOut
            } else if pollRes == -1 {
                throw StreamError.ReadFailed(Int(errno))
            }
        }
        
        var bytes = [UInt8]()
        
        for _ in 0...count {
            bytes.append(0)
        }
        
        #if os(Linux)
            let bytesRead = Glibc.read(fileDescriptor, &bytes, Int(count))
        #else
            let bytesRead = Darwin.read(fileDescriptor, &bytes, Int(count))
        #endif
        
        if bytesRead == -1 {
            throw StreamError.ReadFailed(Int(errno))
        }
        
        if bytesRead == 0 {
            throw StreamError.Closed
        }
        
        return [UInt8](bytes.prefix(bytesRead))
    }
    
    public func write(bytes: [UInt8]) throws -> Int {
        if !canWrite {
            throw StreamError.WriteFailed(0)
        }
        
        if (writeTimeout != 0 && canTimeout) {
            var fds = [pollfd(fd: fileDescriptor, events: Int16(POLLOUT), revents: 0)]
            let pollRes = poll(&fds, 1, Int32(writeTimeout))
        
            if pollRes == 0 {
                throw StreamError.TimedOut
            } else if pollRes == -1 {
                throw StreamError.ReadFailed(Int(errno))
            }
        }
        
        #if os(Linux)
            let bytesWritten = Glibc.write(fileDescriptor, bytes, bytes.count)
        #else
            let bytesWritten = Darwin.write(fileDescriptor, bytes, bytes.count)
        #endif
            
        if bytesWritten == -1 {
            throw StreamError.WriteFailed(Int(errno))
        }
        
        return bytesWritten
    }
    
    public func seek(offset: Int64, origin: SeekOrigin) throws {
        if !canSeek {
            throw StreamError.SeekFailed(0)
        }
        
        var seekOrigin: Int32
        
        switch origin {
        case .Beginning:
            seekOrigin = SEEK_SET
        case .Current:
            seekOrigin = SEEK_CUR
        case .End:
            seekOrigin = SEEK_END
        }
        
        #if os(Linux)
            let result = lseek(fileDescriptor, __off_t(offset), seekOrigin)
        #else
            let result = lseek(fileDescriptor, offset, seekOrigin)
        #endif
            
        if result == -1 {
            throw StreamError.SeekFailed(Int(errno))
        }
    }
    
    public func close() throws {
        #if os(Linux)
            let result = Glibc.close(fileDescriptor)
        #else
            let result = Darwin.close(fileDescriptor)
        #endif
        
        if result == -1 {
            throw StreamError.CloseFailed(Int(errno))
        }
    }
}