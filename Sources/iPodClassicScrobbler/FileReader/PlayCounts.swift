import Foundation

final class PlayCounts: DatabaseElement {
    
    typealias TrackPlayCount = (track: TrackItem, playcount: PlayCountEntry)
        
    override internal class var NAME: String {
        return "mhdp"
    }
    
    internal enum Chunk: ChunkProtocol {
        case singleEntryLength
        case numberOfEntries
        
        public var offset: UInt64 {
            switch(self) {
            case .singleEntryLength:
                return 8
            case .numberOfEntries:
                return 12
            }
        }
        
        public var size: Int {
            return 4
        }
    }
    
    public let singleEntryLength: UInt32
    public let numberOfEntries: UInt32
    
    override init(fileURL: URL, offset: UInt64 = 0) throws {
        let fileHandle = try FileHandle(forReadingFrom: fileURL)
        
        defer {
            try? fileHandle.close()
        }
        
        guard
            let singleEntryLengthData = try? Utils.readChunk(fileHandle: fileHandle, chunk: Chunk.singleEntryLength),
            let singleEntryLength = singleEntryLengthData.parseLEUInt32()
        else {
            throw ReadError.ParseHeaderFieldError(field: "single entry length")
        }
        
        guard
            let numberOfEntriesData = try? Utils.readChunk(fileHandle: fileHandle, chunk: Chunk.numberOfEntries),
            let numberOfEntries = numberOfEntriesData.parseLEUInt32()
        else {
            throw ReadError.ParseHeaderFieldError(field: "number of entries")
        }
        
        self.singleEntryLength = singleEntryLength
        self.numberOfEntries = numberOfEntries
        try super.init(fileURL: fileURL, offset: offset)
    }
    
    public func getAllEntries() throws -> [PlayCountEntry] {
        var entries = [PlayCountEntry]()
        var offset = self.offset + headerLength
        
        for _ in 0...numberOfEntries - 1  {
            let entry = try PlayCountEntry(fileURL: fileURL, offset: offset)
            
            entries.append(entry)
            offset += UInt64(singleEntryLength)
        }
        
        return entries
    }
    
    public func getPlayedTracks(database: Database) throws -> [TrackPlayCount] {
        guard
            let trackDataSet = try database.getTrackDataSet()
        else {
            throw PlayCountError.NoDatabaseData
        }
        
        let trackList = try trackDataSet.getList()
        let tracks = try trackList.getItems()
        
        var playCounts = [TrackPlayCount]()
        var playCountIndexes = [UInt64 : PlayCountEntry]()
        let playCountEntries = try getAllEntries()
        
        for (index, playcountEntry) in playCountEntries.enumerated() {
            playCountIndexes.updateValue(playcountEntry, forKey: UInt64(index))
        }
        
        for (index, playcount) in playCountIndexes {
            guard let track = tracks[safe: Int(index)] else {
                throw ReadError.ElementNotFoundAtIndex(index: index)
            }
            
            let trackPlayCount: TrackPlayCount = (track: track, playcount: playcount)
            playCounts.append(trackPlayCount)
        }
        
        return playCounts
    }
    
}
