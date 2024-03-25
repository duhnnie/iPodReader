import Foundation

internal struct TrackList: ListProtocol {
    
    internal static let NAME = "mhlt"
    
    private enum Chunk: ChunkProtocol {
        case headerID
        case headerLength
        case trackCount
        
        public var offset: UInt64 {
            switch(self) {
            case .headerID:
                return 0
            case .headerLength:
                return 4
            case .trackCount:
                return 8
            }
        }
        
        public var size: Int {
            return 4
        }
    }
    
    private let headerLength: UInt64
    public let itemsCount: Int
    
    init(fileURL: URL, offset: UInt64) throws {
        let fileHandle = try FileHandle(forReadingFrom: fileURL)
        
        try Utils.checkElementId(fileHandle: fileHandle, chunk: Chunk.headerID, id: Self.NAME, offset: offset)
        
        guard
            let headerLengthData = try? Utils.readChunk(
                fileHandle: fileHandle,
                chunk: Chunk.headerLength,
                offset: offset
            ),
            let headerLengthInt32 = headerLengthData.parseLEUInt32()
        else {
            throw ReadError.ParseHeaderFieldError(field: String(describing: Chunk.headerLength))
        }
        
        self.headerLength = UInt64(headerLengthInt32)
        
        guard
            let trackCountData = try? Utils.readChunk(
                fileHandle: fileHandle,
                chunk: Chunk.trackCount,
                offset: offset
            ),
            let trackCountInt32 = trackCountData.parseLEUInt32()
        else {
            throw ReadError.ParseHeaderFieldError(field: String(describing: Chunk.trackCount))
        }
        
        self.itemsCount = Int(trackCountInt32)
    }
    
}
