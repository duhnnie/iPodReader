import Foundation

internal class Element {
    
    internal class var NAME: String {
        return "element"
    }
    
    internal enum Chunk: ChunkProtocol {
        case headerID
        case headerLength
        
        public var offset: UInt64 {
            switch(self) {
            case .headerID:
                return 0
            case .headerLength:
                return 4
            }
        }
        
        public var size: Int {
            return 4
        }
        
    }
    
    public let offset: UInt64
    public let fileURL: URL
    public let headerLength: UInt64
    
    internal init(fileURL: URL, offset: UInt64) throws {
        let fileHandle = try FileHandle(forReadingFrom: fileURL)
        
        defer {
            try? fileHandle.close()
        }
        
        try Utils.checkElementId(fileHandle: fileHandle, chunk: Element.Chunk.headerID, id: Self.NAME, offset: offset)
        
        guard
            let headerLengthData = try? Utils.readChunk(
                fileHandle: fileHandle,
                chunk: Element.Chunk.headerLength,
                parentOffset: offset
            ),
            let headerLengthInt32 = headerLengthData.parseLEUInt32()
        else {
            throw ReadError.ParseHeaderFieldError(field: String(describing: Chunk.headerLength))
        }
        
        self.headerLength = UInt64(headerLengthInt32)
        self.fileURL = fileURL
        self.offset = offset
    }
    
}
