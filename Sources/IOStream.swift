#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

public var stdout = IOStream(fileDescriptor: STDOUT_FILENO, canRead: false)
public var stdin = IOStream(fileDescriptor: STDIN_FILENO, canWrite: false)
public var stderr = IOStream(fileDescriptor: STDERR_FILENO, canRead: false)

public class IOStream: Stream {
    public let fileDescriptor: Int32
    public let canRead: Bool
    public let canWrite: Bool
    
    init(fileDescriptor: Int32, canRead: Bool = true, canWrite: Bool = true) {
        self.fileDescriptor = fileDescriptor
        self.canRead = canRead
        self.canWrite = canWrite
    }
    
    public func read(count: Int) throws -> [UInt8] {
        if !canRead {
            throw StreamError.ReadFailed(0)
        }
        
        var bytes = [UInt8]()
        
        for _ in 0...count {
            bytes.append(0)
        }
        
        #if os(Linux)
            let bytesRead = Glibc.read(fileDescriptor, &bytes, count)
        #else
            let bytesRead = Darwin.read(fileDescriptor, &bytes, count)
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