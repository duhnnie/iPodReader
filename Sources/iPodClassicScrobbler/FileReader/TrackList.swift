import Foundation

class TrackList: Element {
    
    override internal class var NAME: String {
        return "mhlt"
    }
    
    public func getItems() throws -> [TrackItem] {
        var items = [TrackItem]()
        var offset = self.offset + self.headerLength
        
        for _ in 0...self.totalLengthOrChildrenCount - 1 {
            let item = try TrackItem(fileURL: self.fileURL, offset: offset)
            
            items.append(item)
            offset += item.totalLengthOrChildrenCount
        }
        
        return items
    }
    
}
