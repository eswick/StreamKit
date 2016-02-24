
public enum StreamError: ErrorType {
    case ReadFailed(Int)
    case WriteFailed(Int)
    case SeekFailed(Int)
    case CloseFailed(Int)
    case TimedOut
    case Closed
}

public enum SeekOrigin {
    case Beginning
    case Current
    case End
}

public protocol Stream {
    var canRead: Bool { get }
    var canWrite: Bool { get }
    var canTimeout: Bool { get }
    var canSeek: Bool { get }
    
    var position: Int64 { get }
    var readTimeout: UInt { get set } // milliseconds
    var writeTimeout: UInt { get set } // milliseconds
    
    func read(count: Int64) throws -> [UInt8]
    func write(bytes: [UInt8]) throws -> Int
    func seek(offset: Int64, origin: SeekOrigin) throws
    func close() throws
}

public extension Stream {
    
    public func write<T>(value: T) throws {
        var tmpValue = value
        try withUnsafePointer(&tmpValue) { pointer in
            let int8ptr = unsafeBitCast(pointer, UnsafePointer<UInt8>.self)
            let buf = UnsafeBufferPointer(start: int8ptr, count: sizeof(T))
            
            try self.write(Array(buf))
        }
    }
    
    public func read<T>() throws -> T {
        let byteArray = try read(Int64(sizeof(T)))
        
        return byteArray.withUnsafeBufferPointer() { pointer in
            UnsafePointer<T>(pointer.baseAddress).memory
        }
    }
    
    public func readAll() throws -> [UInt8] {
        try seek(0, origin: .End)
        let end = position
        try seek(0, origin: .Beginning)
        
        return try read(end)
    }
}

func << <T>(left: Stream, right: T) throws {
    try left.write(right)
}

func >> <T>(left: Stream, inout right: T) throws {
    right = try left.read()
}
