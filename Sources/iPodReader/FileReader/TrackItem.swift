import Foundation

class TrackItem: ITunesDBElement {
    
    override internal class var NAME: String {
        return "mhit"
    }
    
    public enum MediaType: Int {
        case AudioVideo = 0
        case Audio = 1
        case Video = 2
        case Podcast = 4
        case Unknown = 5
        case VideoPodcast = 6
        case Audiobook = 8
        case MusicVideo = 32
        case TVShow = 64
        case TVShow2 = 96
    }
    
    internal enum Chunk: ChunkProtocol {
        case stringsCount
        case rating
        case length
        case trackNumber
        case totalTracks
        case year
        case discNumber
        case totalDiscs
        case mediaType
        
        public var offset: UInt64 {
            switch(self) {
            case .stringsCount:
                return 12
            case .rating:
                return 31
            case .length:
                return 40
            case .trackNumber:
                return 44
            case .totalTracks:
                return 48
            case .year:
                return 52
            case .discNumber:
                return 92
            case .totalDiscs:
                return 96
            case .mediaType:
                return 208
            }
        }
        
        public var size: Int {
            switch(self) {
            case
                .stringsCount,
                .length,
                .trackNumber,
                .totalTracks,
                .year,
                .discNumber,
                .totalDiscs,
                .mediaType:
                return 4
            case .rating:
                return 1
            }
        }
    }
    
    public let rating: UInt8
    public let length: UInt32
    public let trackNumber: UInt32
    public let totalTracks: UInt32
    public let year: UInt32
    public let discNumber: UInt32
    public let totalDiscs: UInt32
    public let mediaType: MediaType
    public let itemsCount: UInt32
    
    override public init(fileURL: URL, offset: UInt64) throws {
        let fileHandle = try FileHandle(forReadingFrom: fileURL)
        
        defer {
            try? fileHandle.close()
        }
        
        rating = try Utils.readAndParseUIntChunk(
            fileHandle: fileHandle,
            chunk: Chunk.rating,
            type: UInt8.self,
            baseOffset: offset
        )
        
        length = try Utils.readAndParseUIntChunk(
            fileHandle: fileHandle,
            chunk: Chunk.length,
            type: UInt32.self,
            baseOffset: offset
        )
        
        trackNumber = try Utils.readAndParseUIntChunk(
            fileHandle: fileHandle,
            chunk: Chunk.trackNumber,
            type: UInt32.self,
            baseOffset: offset
        )
        
        totalTracks = try Utils.readAndParseUIntChunk(
            fileHandle: fileHandle,
            chunk: Chunk.totalTracks,
            type: UInt32.self,
            baseOffset: offset
        )
        
        year = try Utils.readAndParseUIntChunk(
            fileHandle: fileHandle,
            chunk: Chunk.year,
            type: UInt32.self,
            baseOffset: offset
        )
        
        discNumber = try Utils.readAndParseUIntChunk(
            fileHandle: fileHandle,
            chunk: Chunk.discNumber,
            type: UInt32.self,
            baseOffset: offset
        )
        
        totalDiscs = try Utils.readAndParseUIntChunk(
            fileHandle: fileHandle,
            chunk: Chunk.totalDiscs,
            type: UInt32.self,
            baseOffset: offset
        )
        
        let mediaTypeValue = try Utils.readAndParseUIntChunk(fileHandle: fileHandle, chunk: Chunk.mediaType, type: UInt32.self, baseOffset: offset)
        
        guard let mediaType = MediaType(rawValue: Int(mediaTypeValue)) else {
            throw ReadError.ParseHeaderFieldError(field: "media type")
        }
        
        self.mediaType = mediaType
        
        itemsCount = try Utils.readAndParseUIntChunk(
            fileHandle: fileHandle,
            chunk: Chunk.stringsCount,
            type: UInt32.self,
            baseOffset: offset
        )
        
        try super.init(fileURL: fileURL, offset: offset)
    }
    
    public func getItems() throws -> [DataObject] {
        var items = [DataObject]()
        var offset = self.offset + headerLength
        
        for _ in 0...self.itemsCount - 1 {
            let item = try DataObject(fileURL: fileURL, offset: offset)
            
            items.append(item)
            offset += item.totalLengthOrChildrenCount
        }
        
        return items
    }
    
}
