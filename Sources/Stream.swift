
protocol Stream {
    func read(maxBytes: Int) throws -> [UInt8]
    func write(bytes: [UInt8]) throws -> Int
    func close()
}
