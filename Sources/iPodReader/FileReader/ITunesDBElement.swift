import Foundation

public class ITunesDBElement: Element {
    
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
    
    // NOTE: maybe it should be UInt32
    public let totalLengthOrChildrenCount: UInt64
    
    internal override init(fileURL: URL, offset: UInt64) throws {
        let fileHandle = try FileHandle(forReadingFrom: fileURL)
        
        defer {
            try? fileHandle.close()
        }
        
        self.totalLengthOrChildrenCount = try UInt64(Utils.readAndParseUIntChunk(
            fileHandle: fileHandle,
            chunk: Chunk.totalLengthOrChildrenCount,
            type: UInt32.self,
            baseOffset: offset
        ))
        
        try super.init(fileURL: fileURL, offset: offset)
    }
    
}
