
public protocol Stream {
    func read(maxBytes: Int) throws -> [UInt8]
    func write(bytes: [UInt8]) throws -> Int
    func close() throws
}

extension Stream {
    func readUInt8() throws -> UInt8 {
        return try read(1)[0]
    }
    
    func readInt8() throws -> Int8 {
        return try read(1)[0]
    }
    
    func writeInt8(int8: Int8) throws {
        try write([int8])
    }
    
    func write(uint8: UInt8) throws {
        try write([uint8])
    }
}