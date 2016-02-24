

public class MemoryStream: Stream {
    public let canRead: Bool = true
    public let canWrite: Bool = true
    public let canTimeout: Bool = false
    public let canSeek: Bool = true
    
    public var position: Int64 = 0
    public var readTimeout: UInt = 0
    public var writeTimeout: UInt = 0
    
    public var buffer = [UInt8]()
    
    public func read(count: Int64) throws -> [UInt8] {
        var realCount = count
        
        if Int(position + count) > buffer.count {
            realCount = Int64(buffer.count - Int(position))
        }
        
        if realCount == 0 {
            throw StreamError.ReadFailed(0)
        }
        
        let slice = Array(buffer[Int(position)...Int(position + realCount - 1)])
        position += realCount
        
        return slice
    }
    
    public func write(bytes: [UInt8]) throws -> Int {
        
        if Int(position + bytes.count) >= buffer.count {
            for _ in buffer.count...(Int(position + bytes.count)) {
                buffer.append(0)
            }
        }
        
        buffer.replaceRange(Int(position)...(Int(position + bytes.count)), with: bytes)
        
        position += bytes.count
        
        return bytes.count
    }
    
    public func seek(offset: Int64, origin: SeekOrigin) throws {
        var refPoint: Int
        
        switch origin {
        case .Beginning:
            refPoint = 0
            break
        case .Current:
            refPoint = Int(position)
            break
        case .End:
            refPoint = buffer.count - 1
        }
        
        if Int(refPoint + offset) >= Int(buffer.count) {
            throw StreamError.SeekFailed(0)
        }
        
        position = refPoint + offset
    }
    
    public init() {
        
    }
    
    public func close() throws {
        
    }
}