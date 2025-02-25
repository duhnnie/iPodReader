import Foundation

internal struct Utils {
    
    public static func readChunk(fileHandle: FileHandle, offset: UInt64, size: Int) throws -> Data {
        try fileHandle.seek(toOffset: offset)
        return fileHandle.readData(ofLength: size)
    }
    
    public static func readChunk(fileHandle: FileHandle, chunk: ChunkProtocol, baseOffset: UInt64 = 0) throws -> Data {
        return try Self.readChunk(fileHandle: fileHandle, offset: baseOffset + chunk.offset, size: chunk.size)
    }
    
    public static func checkElementId(fileHandle: FileHandle, chunk: ChunkProtocol, id: String, offset:UInt64) throws {
        try fileHandle.seek(toOffset: offset + chunk.offset)
        
        let idData = fileHandle.readData(ofLength: chunk.size)
        
        guard
            let idString = String(data: idData, encoding: .utf8),
            idString == id
        else {
            throw ReadError.NoElementMatchError(expected: id)
        }
    }
    
    public static func readAndParseUIntChunk<T: UnsignedInteger>(fileHandle: FileHandle, chunk: ChunkProtocol, type: T.Type, baseOffset: UInt64 = 0) throws -> T {
        guard
            let data = try? readChunk(fileHandle: fileHandle, chunk: chunk, baseOffset: baseOffset),
            let parsed = data.parseLEUIntX(type)
        else {
            throw ReadError.ParseHeaderFieldError(field: "\(chunk)")
        }
        
        return parsed
    }
    
    public static func readAndParseToString(fileHandle: FileHandle, chunk: ChunkProtocol, encoding: String.Encoding, baseOffset: UInt64 = 0) throws -> String {
        guard
            let languageData = try? Utils.readChunk(fileHandle: fileHandle, chunk: chunk),
            let language = String(data: languageData, encoding: encoding)
        else {
            throw ReadError.ParseHeaderFieldError(field: "\(chunk)")
        }
        
        return language
    }
    
}
