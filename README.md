# iPodReader

iPodReader is a project written in swift for reading the iTunesDB and PlayCounts file in Apple iPod devices. Currently it only reads the tracks in the _iTunesDB_ file and the play count entries in the _PlayCounts_ file. This can be used for get the play count for every played track in the device since its last sync.

This project was tested in a Mac-formatted iPod Classic with software version 2.0.4.

## Instalation

### Swift Package Manager

The [Swift Package Manager][] is a tool for managing the distribution of
Swift code.

1. Add the following to your `Package.swift` file:

  ```swift
  dependencies: [
      .package(url: "https://github.com/duhnnie/iPodReader", from: "X.Y.Z")
  ]
  ```

2. Build your project:

  ```sh
  $ swift build
  ```

[Swift Package Manager]: https://swift.org/package-manager

### Carthage

[Carthage][] is a simple, decentralized dependency manager for Cocoa. To
install iPodReader with Carthage:

 1. Make sure Carthage is [installed][Carthage Installation].

 2. Update your Cartfile to include the following:

    ```ruby
    github "duhnnie/iPodReader" ~> X.Y.Z
    ```

 3. Run `carthage update` and
    [add the appropriate framework][Carthage Usage].


[Carthage]: https://github.com/Carthage/Carthage
[Carthage Installation]: https://github.com/Carthage/Carthage#installing-carthage
[Carthage Usage]: https://github.com/Carthage/Carthage#adding-frameworks-to-an-application

### CocoaPods

[CocoaPods][] is a dependency manager for Cocoa projects. To install
iPodReader with CocoaPods:

 1. Make sure CocoaPods is [installed][CocoaPods Installation].

    ```sh
    # Using the default Ruby install will require you to use sudo when
    # installing and updating gems.
    [sudo] gem install cocoapods
    ```

 2. Update your Podfile to include the following:

    ```ruby
    use_frameworks!

    target 'YourAppTargetName' do
        pod 'iPodReader', '~> X.Y.Z'
    end
    ```

 3. Run `pod install --repo-update`.

[CocoaPods]: https://cocoapods.org
[CocoaPods Installation]: https://guides.cocoapods.org/using/getting-started.html#getting-started

## Usage
You will need access to the following files inside the iPod:
- /iPod_Control/iTunes/iTunesDB
- /iPod_Control/iTunes/Play Counts

**iTunesDB** is the primary database for the iPod. It contains all information about the songs that the iPod is capable of playing, as well as the playlists. It's never written to by the Apple iPod firmware. During an autosync, iTunes completely overwrites this file.

**Play Counts** is the return information file for the iPod. It contains all information that is available to change via the iPod, with regards to the song. When you autosync, iTunes reads this file and updates the iTunes database accordingly. After it does this, it erases this file, so as to prevent it from duplicating data by mistake. The iPod will create this file on playback if it is not there.

More info: http://www.ipodlinux.org/ITunesDB/#Basic_information

```swift
import Foundation
import iPodReader

var playCountsFileURL = URL(fileURLWithPath: "/users/daniel/Documents", isDirectory: true)
playCountsFileURL.appendPathComponent("iPodReaderProject", isDirectory: true)
playCountsFileURL.appendPathComponent("Play Counts", isDirectory: false)

var fileURL = URL(fileURLWithPath: "/users/daniel/Documents", isDirectory: true)
fileURL.appendPathComponent("iPodReaderProject", isDirectory: true)
fileURL.appendPathComponent("iTunesDB", isDirectory: false)

let iTunesDB = try iPodReader.ITunesDB(fileURL: fileURL)
let playCountsDB = try iPodReader.PlayCountsDB(fileURL: playCountsFileURL)
let playedTracks = try playCountsDB.getPlayedTracks(database: iTunesDB)

let sortedPlayedTracks: [PlayCountsDB.TrackPlayCount] = playedTracks.sorted { trackA, trackB in
    return trackA.playcount.lastPlayed < trackB.playcount.lastPlayed
}

for (track, playcount) in sortedPlayedTracks {
    // Filtering out all media that is not audio and music video
    if ![TrackItem.MediaType.Audio, TrackItem.MediaType.MusicVideo].contains(track.mediaType) {
        continue
    }

    let trackStrings = try track.getItems()

    guard
        let artist = trackStrings.first(where: { $0.type == DataObject.DataObjectType.artist }),
        let title = trackStrings.first(where: { $0.type == DataObject.DataObjectType.title })
    else {
        print("Error")
        exit(EX_OK)
    }

    // timestamps are in Mac HFS+ Timestamp, so we need to convert to UNIX timestamp by substracting 2082844800
    let rawDate = Date(timeIntervalSince1970: TimeInterval(playcount.lastPlayed - 2082844800))
    let lastPlayed = rawDate.addingTimeInterval(TimeInterval(TimeZone.current.secondsFromGMT()) * -1)

    print("\(playcount.playCount) - \(artist.value) - \"\(title.value)\" - \(lastPlayed)")
}

```


## Contribution

 If you want to contribute to this project, report a bug or ask for support for another iPod model just open a ticket in Issues section or write to me.


## Original author

 - [Daniel Canedo](mailto:me@duhnnie.net)
   ([@duhnnie](https://twitter.com/duhnnie))


## License

iPodReader is available under the MIT license. See [the LICENSE
file](./LICENSE.txt) for more information.