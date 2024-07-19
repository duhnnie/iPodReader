import Foundation

class TrackItem: Element {
    
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
        
        // Rating:
        guard
            let ratingData = try? Utils.readChunk(fileHandle: fileHandle, chunk: Chunk.rating, parentOffset: offset),
            let ratingData8 = ratingData.parseLEUInt8()
        else {
            throw ReadError.ParseHeaderFieldError(field: "rating")
        }
        
        self.rating = ratingData8 / 20
        
        // Length:
        guard
            let lengthData = try? Utils.readChunk(fileHandle: fileHandle, chunk: Chunk.length, parentOffset: offset),
            let lengthData32 = lengthData.parseLEUInt32()
        else {
            throw ReadError.ParseHeaderFieldError(field: "length")
        }
        
        self.length = lengthData32
        
        // Track Number
        guard
            let trackNumberData = try? Utils.readChunk(fileHandle: fileHandle, chunk: Chunk.trackNumber, parentOffset: offset),
            let trackNumber32 = trackNumberData.parseLEUInt32()
        else {
            throw ReadError.ParseHeaderFieldError(field: "track number")
        }
        
        self.trackNumber = trackNumber32
        
        // Total tracks
        guard
            let totalTracksData = try? Utils.readChunk(fileHandle: fileHandle, chunk: Chunk.totalTracks, parentOffset: offset),
            let totalTracks32 = totalTracksData.parseLEUInt32()
        else {
            throw ReadError.ParseHeaderFieldError(field: "total tracks")
        }
        
        self.totalTracks = totalTracks32
        
        // Year
        guard
            let yearData = try? Utils.readChunk(fileHandle: fileHandle, chunk: Chunk.year, parentOffset: offset),
            let year32 = yearData.parseLEUInt32()
        else {
            throw ReadError.ParseHeaderFieldError(field: "year")
        }
        
        self.year = year32
        
        // Disc number
        guard
            let discNumberData = try? Utils.readChunk(fileHandle: fileHandle, chunk: Chunk.discNumber, parentOffset: offset),
            let discNumber = discNumberData.parseLEUInt32()
        else {
            throw ReadError.ParseHeaderFieldError(field: "disc number")
        }
        
        self.discNumber = discNumber
        
        // Total discs
        guard
            let totalDiscsData = try? Utils.readChunk(fileHandle: fileHandle, chunk: Chunk.totalDiscs, parentOffset: offset),
            let totalDiscs = totalDiscsData.parseLEUInt32()
        else {
            throw ReadError.ParseHeaderFieldError(field: "total discs")
        }
        
        self.totalDiscs = totalDiscs
        
        // Media type
        guard
            let mediaTypeData = try? Utils.readChunk(fileHandle: fileHandle, chunk: Chunk.mediaType, parentOffset: offset),
            let mediaTypeValue = mediaTypeData.parseLEUInt32(),
            let mediaType = MediaType(rawValue: Int(mediaTypeValue))
        else {
            throw ReadError.ParseHeaderFieldError(field: "media type")
        }
        
        self.mediaType = mediaType
        
        // Items count / strings count
        guard
            let itemsCountData = try? Utils.readChunk(fileHandle: fileHandle, chunk: Chunk.stringsCount, parentOffset: offset),
            let itemsCount = itemsCountData.parseLEUInt32()
        else {
            throw ReadError.ParseHeaderFieldError(field: "media type")
        }
        
        self.itemsCount = itemsCount
        
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
