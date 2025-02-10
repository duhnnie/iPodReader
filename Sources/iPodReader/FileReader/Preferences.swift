import Foundation

public final class Preferences {
    internal enum Chunk: ChunkProtocol {
        case timezone
        
        public var offset: UInt64 {
            switch(self) {
            case .timezone:
                return 2940
            }
        }
        
        public var size: Int {
            return 4
        }
    }
    
    private static let UTC_REFERENCE = 76_925
    private let timestampRaw: Int
    
    public var timeOffsetInSeconds: Int {
        let normalized = self.timestampRaw - (self.timestampRaw % 5)
        let utcDiff = normalized - Self.UTC_REFERENCE
        
        if utcDiff > (12 * 60 * 60) {
            return utcDiff - (24 * 60 * 60)
        } else if utcDiff < (-12 * 60 * 60) {
            return utcDiff + (24 * 60 * 60)
        }
        
        return utcDiff
    }
    
    public init(fileURL: URL) throws {
        let fileHandle = try FileHandle(forReadingFrom: fileURL)
        
        defer {
            try? fileHandle.close()
        }
        
        let timestampRaw32 = try Utils.readAndParseUIntChunk(
            fileHandle: fileHandle,
            chunk: Chunk.timezone,
            type: UInt32.self
        )
        
        self.timestampRaw = Int(timestampRaw32)
    }

}
