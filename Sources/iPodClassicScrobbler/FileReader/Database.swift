import Foundation

final class Database: Element {
    
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
    
    public let version: UInt
    public let childrenCount: UInt
    public let id: UInt64
    public let language: String
    
    public init(fileURL: URL) throws {
        let fileHandle = try FileHandle(forReadingFrom: fileURL)
        
        defer {
            try? fileHandle.close()
        }
        
        guard
            let versionData = try? Utils.readChunk(fileHandle: fileHandle, chunk: Chunk.versionNumber),
            let version32 = versionData.parseLEUInt32()
        else {
            throw ReadError.ParseHeaderFieldError(field: "version")
        }
        
        self.version = UInt(version32)
        
        guard
            let childrenCountData = try? Utils.readChunk(fileHandle: fileHandle, chunk: Chunk.childrenCount),
            let childrenCountInt32 = childrenCountData.parseLEUInt32()
        else {
            throw ReadError.ParseHeaderFieldError(field: "childrenCountData")
        }
        
        self.childrenCount = UInt(childrenCountInt32)
        
        guard
            let idData = try? Utils.readChunk(fileHandle: fileHandle, chunk: Chunk.id),
            let idInt64 = idData.parseLEUInt64()
        else {
            throw ReadError.ParseHeaderFieldError(field: "id")
        }
        
        self.id = idInt64
        
        guard
            let languageData = try? Utils.readChunk(fileHandle: fileHandle, chunk: Chunk.language),
            let language = String(data: languageData, encoding: .utf8)
        else {
            throw ReadError.ParseHeaderFieldError(field: "language")
        }
        
        self.language = language
        
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
