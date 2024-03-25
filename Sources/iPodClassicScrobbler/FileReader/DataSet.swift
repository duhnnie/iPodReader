import Foundation

internal struct DataSet {
    
    private static let NAME = "mhsd"
    
    public enum DataSetType: Int {
        case Track = 1
        case Playlist = 2
        case Podcast = 3
        case Album = 4
        case NewPlaylist = 5
        case Unknown = 9
    }
    
    private enum Chunk: ChunkProtocol {
        case headerID
        case headerLength
        case totalLength
        case type
        
        public var offset: UInt64 {
            switch(self) {
            case .headerID:
                return 0
            case .headerLength:
                return 4
            case .totalLength:
                return 8
            case .type:
                return 12
            }
        }
        
        public var size: Int {
            return 4
        }
    }
    
    private let headerLength: UInt64
    private let fileURL: URL
    public let totalLength: UInt64
    public let type: DataSetType
    
    init(fileURL: URL, offset: UInt64) throws {
        let fileHandle = try FileHandle(forReadingFrom: fileURL)
        
        defer {
            try? fileHandle.close()
        }
        
        let headerIDData = try Utils.readChunk(fileHandle: fileHandle, chunk: Chunk.headerID, offset: offset)
        let headerID = String(data: headerIDData, encoding: .utf8)
        
        guard headerID == Self.NAME else {
            throw ReadError.NoElementMatchError(expected: Self.NAME)
        }
        
        let headerLengthData = try Utils.readChunk(fileHandle: fileHandle, chunk: Chunk.headerLength, offset: offset)
        self.headerLength = UInt64(headerLengthData.parseLEUInt32()!)
        
        let totalLengthData = try Utils.readChunk(fileHandle: fileHandle, chunk: Chunk.totalLength, offset: offset)
        self.totalLength = UInt64(totalLengthData.parseLEUInt32()!)
        
        let typeData = try Utils.readChunk(fileHandle: fileHandle, chunk: Chunk.type, offset: offset)
        
        guard
            let typeInt32 = typeData.parseLEUInt32(),
            let type = DataSetType(rawValue: Int(typeInt32))
        else {
            throw ReadError.EnumParseError(type: String(describing: DataSetType.self))
        }
        
        self.type = type
        self.fileURL = fileURL
    }
    
//    public func getList() throws -> ListProtocol {
//        let fileHandle = try FileHandle(forReadingFrom: self.fileURL)
//    }
}
