
public enum StreamError: ErrorType {
    case ReadFailed(Int)
    case WriteFailed(Int)
    case CloseFailed(Int)
    case Closed
}

public protocol Stream {
    func read(count: Int) throws -> [UInt8]
    func write(bytes: [UInt8]) throws -> Int
    func close() throws
}

public extension Stream {
    func readInt8() throws -> Int8 {
        return Int8(try read(1)[0])
    }
    
    func write(int8: Int8) throws {
        try write([UInt8(int8)])
    }
    
    func readUInt8() throws -> UInt8 {
        return try read(1)[0]
    }
    
    func write(uint8: UInt8) throws {
        try write([uint8])
    }
    
    func readString() throws -> String {
        var str = ""
        
        while true {
            let byte = try read(1)[0]
            
            if byte == 0x0 {
                return str
            } else {
                str.appendContentsOf(String(UnicodeScalar(byte)))
            }
        }
    }
    
    func write(string: String) throws {
        try write([UInt8](string.utf8))
    }
}
