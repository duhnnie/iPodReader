import Foundation

internal struct Database {
    
    private enum Chunk: ChunkProtocol {
        case headerID
        case headerLength
        case totalLength
        case versionNumber
        case childrenCount
        case id
        case language
        
        public var offset: UInt64 {
            switch(self) {
            case .headerID:
                return 0
            case .headerLength:
                return 4
            case .totalLength:
                return 8
            case .versionNumber:
                return 16
            case .childrenCount:
                return 20
            case .id:
                return 24
            case .language:
                return 70
            }
        }
        
        public var size: Int {
            switch(self) {
            case .headerID,
                .headerLength,
                .totalLength,
                .versionNumber,
                .childrenCount:
                return 4
            case .id:
                return 8
            case .language:
                return 2
            }
        }
    }
    
    private static let NAME = "mhbd"
    private let fileURL: URL
    private let headerLength: UInt64
    private let totalLength: UInt64
    
    public let version: UInt
    public let childrenCount: UInt
    public let id: UInt64
    public let language: String
    
    init(fileURL: URL) throws {
        let fileHandle = try FileHandle(forReadingFrom: fileURL)
        
        defer {
            try? fileHandle.close()
        }
        
        let headerID = try String(data: Utils.readChunk(fileHandle: fileHandle, chunk: Chunk.headerID), encoding: .utf8)
        
        guard headerID == Self.NAME else {
            throw ReadError.NoElementMatchError(expected: Self.NAME)
        }
        
        headerLength = UInt64(try Utils.readChunk(fileHandle: fileHandle, chunk: Chunk.headerLength).parseLEUInt32()!)
        totalLength = UInt64(try Utils.readChunk(fileHandle: fileHandle, chunk: Chunk.totalLength).parseLEUInt32()!)
        version = UInt(try Utils.readChunk(fileHandle: fileHandle, chunk: Chunk.versionNumber).parseLEUInt32()!)
        childrenCount = UInt(try Utils.readChunk(fileHandle: fileHandle, chunk: Chunk.childrenCount).parseLEUInt32()!)
        id = UInt64(try Utils.readChunk(fileHandle: fileHandle, chunk: Chunk.id).parseLEUInt64()!)
        language = try String(data: Utils.readChunk(fileHandle: fileHandle, chunk: Chunk.language), encoding: .utf8)!
        
        self.fileURL = fileURL
        
        try fileHandle.close()
    }
 
    private func getChildren() throws -> [DataSet] {
        var datasets = [DataSet]()
        var offset = self.headerLength
        
        for _ in 0...self.childrenCount - 1 {
            let dataSet = try DataSet(fileURL: self.fileURL, offset: offset)
            
            datasets.append(dataSet)
            offset += dataSet.totalLength
        }
        
        return datasets
    }
    
    public func getTrackDataSet() throws -> DataSet? {
        let children = try self.getChildren()
        
        return children.first { dataSet in
            return dataSet.type == DataSet.DataSetType.Track
        }
    }
}
