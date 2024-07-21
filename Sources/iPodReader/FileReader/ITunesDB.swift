import Foundation

public final class ITunesDB: ITunesDBElement {
    
    override internal class var NAME: String {
        return "mhbd"
    }
    
    internal enum Chunk: ChunkProtocol {
        case versionNumber
        case childrenCount
        case id
        case language
        
        public var offset: UInt64 {
            switch(self) {
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
            case
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
    
    public let version: UInt32
    public let childrenCount: UInt32
    public let id: UInt64
    public let language: String
    
    public init(fileURL: URL) throws {
        let fileHandle = try FileHandle(forReadingFrom: fileURL)
        
        defer {
            try? fileHandle.close()
        }
        
        version = try Utils.readAndParseUIntChunk(
            fileHandle: fileHandle,
            chunk: Chunk.versionNumber,
            type: UInt32.self
        )
        
        childrenCount = try Utils.readAndParseUIntChunk(
            fileHandle: fileHandle,
            chunk: Chunk.childrenCount,
            type: UInt32.self
        )
        
        id = try Utils.readAndParseUIntChunk(
            fileHandle: fileHandle,
            chunk: Chunk.id,
            type: UInt64.self
        )
        
        language = try Utils.readAndParseToString(
            fileHandle: fileHandle,
            chunk: Chunk.language,
            encoding: .utf8
        )
        
        try super.init(fileURL: fileURL, offset: 0)
    }
    
    private func getChildren() throws -> [DataSet] {
        var datasets = [DataSet]()
        var offset = self.headerLength
        
        for _ in 0...self.childrenCount - 1 {
            let dataSet = try DataSet(fileURL: self.fileURL, offset: offset)
            
            datasets.append(dataSet)
            offset += dataSet.totalLengthOrChildrenCount
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
