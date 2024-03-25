import Foundation

internal protocol ChunkProtocol {
    
    var offset: UInt64  { get }
    var size: Int { get }
    
}
