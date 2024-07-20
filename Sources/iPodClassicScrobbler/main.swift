import Foundation

var pcFileURL = URL(fileURLWithPath: "/users/daniel/Documents", isDirectory: true)
pcFileURL.appendPathComponent("iPodReaderProject", isDirectory: true)
pcFileURL.appendPathComponent("Play Counts", isDirectory: false)

var fileURL = URL(fileURLWithPath: "/users/daniel/Documents", isDirectory: true)
fileURL.appendPathComponent("iPodReaderProject", isDirectory: true)
fileURL.appendPathComponent("iTunesDB", isDirectory: false)

var mhdb = try Database(fileURL: fileURL)
let playcount = try PlayCounts(fileURL: pcFileURL)
let trackPlayCounts = try playcount.getPlayedTracks(database: mhdb)
var maxTimestamp: uint32 = 0

for (track, playcount) in trackPlayCounts {
    if (playcount.playCount < 1 || ![TrackItem.MediaType.Audio, TrackItem.MediaType.MusicVideo].contains(track.mediaType)) {
        continue
    }
    
    if maxTimestamp < playcount.lastPlayed {
        maxTimestamp = playcount.lastPlayed
    }
    
    let strings = try track.getItems()
    let artist = strings.first { str in str.type == DataObject.DataObjectType.artist }
    let title = strings.first { str in str.type == DataObject.DataObjectType.title }
    
    print("\(playcount.playCount): \(artist?.value ?? "[NO ARTIST]") - \"\(title!.value)\" (\(playcount.lastPlayed))")
}

print("last play:", maxTimestamp)

exit(0)
