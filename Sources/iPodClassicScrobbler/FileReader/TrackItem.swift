import Foundation

class TrackItem: Element {
    
    override internal class var NAME: String {
        return "mhit"
    }
    
    internal enum Chunk: ChunkProtocol {
        case stringsCount
        case rating
        case length
        case trackNumber
        case totalTracks
        case year
        case discNumber
        case totalDiscs
        case mediaType
        
        public var offset: UInt64 {
            switch(self) {
            case .stringsCount:
                return 12
            case .rating:
                return 31
            case .length:
                return 40
            case .trackNumber:
                return 44
            case .totalTracks:
                return 48
            case .year:
                return 52
            case .discNumber:
                return 92
            case .totalDiscs:
                return 96
            case .mediaType:
                return 208
            }
        }
        
        public var size: Int {
            switch(self) {
            case
                .stringsCount,
                .length,
                .trackNumber,
                .totalTracks,
                .year,
                .discNumber,
                .totalDiscs,
                .mediaType:
                return 4
            case .rating:
                return 1
            }
        }
    }
}
