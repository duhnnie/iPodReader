import Foundation

internal class DatabaseElement: Element {
    
    override internal class var NAME: String {
        return "databaseElement"
    }
    
    internal enum Chunk: ChunkProtocol {
        case totalLengthOrChildrenCount
        
        public var offset: UInt64 {
            return 8
        }
        
        public var size: Int {
            return 4
        }
    }
    
    public let totalLengthOrChildrenCount: UInt64
    
    internal override init(fileURL: URL, offset: UInt64) throws {
        let fileHandle = try FileHandle(forReadingFrom: fileURL)
        
        defer {
            try? fileHandle.close()
        }
        
        guard
            let totalLength = try? Utils.readChunk(
                fileHandle: fileHandle,
                chunk: DatabaseElement.Chunk.totalLengthOrChildrenCount,
                parentOffset: offset
            ),
            let totalLength32 = totalLength.parseLEUInt32()
        else {
            throw ReadError.ParseHeaderFieldError(field: String(describing: Chunk.totalLengthOrChildrenCount))
        }
        
        self.totalLengthOrChildrenCount = UInt64(totalLength32)
        try super.init(fileURL: fileURL, offset: offset)
    }
    
}
