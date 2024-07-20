import Foundation

internal class PlayCountEntry {
    
    internal enum Chunk: ChunkProtocol {
        case playCount
        case lastPlayed
        case audioBookmark
        case rating
        case unknown
        case skipCount
        case lastSkipped
        
        public var offset: UInt64 {
            switch(self) {
            case .playCount:
                return 0
            case .lastPlayed:
                return 4
            case .audioBookmark:
                return 8
            case .rating:
                return 12
            case .unknown:
                return 16
            case .skipCount:
                return 20
            case .lastSkipped:
                return 24
            }
        }
        
        public var size: Int {
            return 4
        }
    }
    
    
    public let playCount: UInt32
    public let lastPlayed: UInt32
    public let audioBookmark: UInt32
    public let rating: UInt32
    public let skipCount: UInt32
    public let lastSkipped: UInt32
    
    init(fileURL: URL, offset: UInt64) throws {
        let fileHandle = try FileHandle(forReadingFrom: fileURL)
        
        defer {
            try? fileHandle.close()
        }
                
        playCount = try Utils.readAndParseUIntChunk(fileHandle: fileHandle, chunk: Chunk.playCount, type: UInt32.self, baseOffset: offset)
        lastPlayed = try Utils.readAndParseUIntChunk(fileHandle: fileHandle, chunk: Chunk.lastPlayed, type: UInt32.self, baseOffset: offset)
        audioBookmark = try Utils.readAndParseUIntChunk(fileHandle: fileHandle, chunk: Chunk.audioBookmark, type: UInt32.self, baseOffset: offset)
        rating = try Utils.readAndParseUIntChunk(fileHandle: fileHandle, chunk: Chunk.rating, type: UInt32.self, baseOffset: offset)
        skipCount = try Utils.readAndParseUIntChunk(fileHandle: fileHandle, chunk: Chunk.skipCount, type: UInt32.self, baseOffset: offset)
        lastSkipped = try Utils.readAndParseUIntChunk(fileHandle: fileHandle, chunk: Chunk.lastSkipped, type: UInt32.self, baseOffset: offset)
    }
    
}
