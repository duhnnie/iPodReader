import Foundation

class DataObject: ITunesDBElement {
    
    override internal class var NAME: String {
        return "mhod"
    }
    
    public enum DataObjectType: Int {
        case title = 1
        case location
        case album
        case artist
        case genre
        case filetype
        case eqSetting
        case comment
        case category
        case composer = 12
        case grouping
        case description
        case podcastEnclosureURL
        case podcastRSS
        case chapterData
        case subtitle
        case show
        case episodeNumber
        case tvNetwork
        case albumArtist
        case sortingArtist
        case keywords
        case tvShowLocale
        case sortingTitle = 27
        case sortingAlbum
        case sortingAlbumArtist
        case sortingComposer
        case sortingTVShow
        case unknown1
        case smartPlaylistData = 50
        case smartPlaylistRules
        case libraryPlaylistIndex
        case unknown2
        case unknown3 = 100
        case albumInAlbumList = 200
        case artistInAlbumList
        case sortingArtistInAlbumList
        case podcastURLInAlbumList
        case tvShowInAlbumList
    }
    
    private enum Chunk: ChunkProtocol {
        case type
        case length
        
        public var offset: UInt64 {
            switch(self) {
            case .type:
                return 12
            case .length:
                return 28
            }
        }
        
        public var size: Int {
            return 4
        }
    }
    
    public let type: DataObjectType
    private(set) var value: String
    
    override init(fileURL: URL, offset: UInt64) throws {
        let fileHandle = try FileHandle(forReadingFrom: fileURL)
        
        defer {
            try? fileHandle.close()
        }
        
        let typeInt32 = try Utils.readAndParseUIntChunk(
            fileHandle: fileHandle,
            chunk: Chunk.type,
            type: UInt32.self,
            baseOffset: offset
        )
        
        guard
            let type = try? DataObjectType(rawValue: Int(typeInt32)) ?? DataObjectType.unknown1
        else {
            throw ReadError.ParseHeaderFieldError(field: "type")
        }
        
        self.type = type
        self.value = ""
        try super.init(fileURL: fileURL, offset: offset)
        try self.initValue(fileHandle)
    }
    
    private func initValue(_ fileHandle: FileHandle) throws {
        if self.type.rawValue < 15 {
            guard
                let lengthData = try? Utils.readChunk(fileHandle: fileHandle, chunk: Chunk.length, baseOffset: offset),
                let length = lengthData.parseLEUInt32(),
                let valueData = try? Utils.readChunk(fileHandle: fileHandle, offset: offset + 40, size: Int(length)),
                let value = String(data: valueData, encoding: .utf16LittleEndian)
            else {
                throw ReadError.ParseHeaderFieldError(field: "value")
            }

            self.value = value
        } else if [15, 16].contains(self.type.rawValue) {
            guard
                let valueData = try? Utils.readChunk(fileHandle: fileHandle, offset: offset + 24, size: Int(self.totalLengthOrChildrenCount - self.headerLength)),
                let value = String(data: valueData, encoding: .utf8)
            else {
                throw ReadError.ParseHeaderFieldError(field: "value")
            }

            self.value = value
        } else if self.type.rawValue == 17 {
            guard
                let valueData = try? Utils.readChunk(fileHandle: fileHandle, offset: offset + 24, size: Int(self.totalLengthOrChildrenCount - self.headerLength - 12)),
                let value = String(data: valueData, encoding: .utf8)
            else {
                throw ReadError.ParseHeaderFieldError(field: "value")
            }

            self.value = value
        }
    }
    
}
