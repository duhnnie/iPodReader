import Foundation

public class DataSet: ITunesDBElement {
    
    override internal class var NAME: String {
        return "mhsd"
    }
    
    public enum DataSetType: Int {
        case Track = 1
        case Playlist = 2
        case Podcast = 3
        case Album = 4
        case NewPlaylist = 5
        case Unknown = 9
    }
    
    private enum Chunk: ChunkProtocol {
        case type
        
        public var offset: UInt64 {
            switch(self) {
            case .type:
                return 12
            }
        }
        
        public var size: Int {
            return 4
        }
    }
    
    public let type: DataSetType
    
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
            let type = DataSetType(rawValue: Int(typeInt32))
        else {
            throw ReadError.EnumParseError(type: String(describing: DataSetType.self))
        }
        
        self.type = type
        
        try super.init(fileURL: fileURL, offset: offset)
    }
    
    public func getList() throws -> TrackList {
        return try TrackList(fileURL: self.fileURL, offset: self.offset + self.headerLength)
    }
}
