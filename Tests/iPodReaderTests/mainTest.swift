import XCTest
@testable import iPodReader

final class mainTest: XCTestCase {
    func testEverything() throws {
        let iTunesDBURL = Bundle.module.url(forResource: "Resources/iTunesDB", withExtension: "")!
        let playCountsURL = Bundle.module.url(forResource: "Resources/Play Counts", withExtension: "")!
        
        let mhdb = try ITunesDB(fileURL: iTunesDBURL)
        let playcount = try PlayCountsDB(fileURL: playCountsURL)
        let trackPlayCounts = try playcount.getPlayedTracks(database: mhdb)
        var maxTimestamp: UInt32 = 0

        for (track, playcount) in trackPlayCounts {
            if maxTimestamp < playcount.lastPlayed {
                maxTimestamp = playcount.lastPlayed
            }
            
            let strings = try track.getItems()
            let artist = strings.first { str in str.type == DataObject.DataObjectType.artist }
            let title = strings.first { str in str.type == DataObject.DataObjectType.title }
            
            print("\(playcount.playCount): \(artist?.value ?? "[NO ARTIST]") - \"\(title!.value)\" (\(playcount.lastPlayed))")
        }

        print("last play:", maxTimestamp)
    }
    
}
