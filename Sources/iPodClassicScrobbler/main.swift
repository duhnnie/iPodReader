import Foundation

struct Playcount {
    let index: Int
    let count: UInt64
    let rating: UInt
    let timestamp: UInt64
}

print("Hello, world!")

var pcFileURL = URL(fileURLWithPath: "/users/daniel/Documents", isDirectory: true)
pcFileURL.appendPathComponent("iPodReaderProject", isDirectory: true)
pcFileURL.appendPathComponent("Play Counts", isDirectory: false)

guard let pcFileHandle = FileHandle(forReadingAtPath: pcFileURL.path) else {
    print("can't read file at \(pcFileURL.path)")
    exit(EXIT_FAILURE)
}

var pcDataBuffer: Data
try pcFileHandle.seek(toOffset: 4) // skip header id
pcDataBuffer = pcFileHandle.readData(ofLength: 4)
let pcHeaderLength = UInt64(pcDataBuffer.parseLEUInt8()!)
pcDataBuffer = pcFileHandle.readData(ofLength: 4)
let pcSingleEntryLength = UInt64(pcDataBuffer.parseLEUInt8()!)
pcDataBuffer = pcFileHandle.readData(ofLength: 4)
let pcNumberOfEntries = UInt64(pcDataBuffer.parseLEUInt8()!)
print(pcNumberOfEntries)

var pcOffset = pcHeaderLength
var playcountItems = [Playcount]()

if pcNumberOfEntries > 0 {
    try pcFileHandle.seek(toOffset: pcOffset)
    var i = 0
    
    while pcOffset < pcFileHandle.seekToEndOfFile() {
        try pcFileHandle.seek(toOffset: pcOffset)
        pcDataBuffer = pcFileHandle.readData(ofLength: 4)

        let playCount = UInt64(pcDataBuffer.parseLEUInt8()!)
        try pcFileHandle.seek(toOffset: pcOffset + 12)
        pcDataBuffer = pcFileHandle.readData(ofLength: 4)
        let rating = UInt(pcDataBuffer.parseLEUInt32()!) / 20

//        if playCount > 0 {
        playcountItems.append(Playcount(index: Int(i), count: playCount, rating: rating, timestamp: 0))
//            print("\(i). \(playCount) - \(playcountItems.count)")
//        } else {
//            print("\(i). \(playCount) - \(playcountItems.count)")
//        }

        pcOffset += pcSingleEntryLength
        try pcFileHandle.seek(toOffset: pcOffset)
        i += 1
    }
}

//exit(0)

// -------------------

var fileURL = URL(fileURLWithPath: "/users/daniel/Documents", isDirectory: true)

fileURL.appendPathComponent("iPodReaderProject", isDirectory: true)
fileURL.appendPathComponent("iTunesDB", isDirectory: false)

//var mhdb = try Database(fileURL: fileURL)
var mhdb = try Database(fileURL: fileURL)
var trackDataSet = try mhdb.getTrackDataSet()
var trackList = try trackDataSet!.getList()
var items = try trackList.getItems()
//print(try mhdb.getTrackDataSet())
print(items.count)

let formatter = DateComponentsFormatter()
formatter.allowedUnits = [.hour, .minute, .second]
formatter.unitsStyle = .full

for item in items {
    if item.rating < 5 {
        continue
    }
    
    
    let strings = try item.getItems()
    let artist = strings.first { str in str.type == DataObject.DataObjectType.artist }
    let title = strings.first { str in str.type == DataObject.DataObjectType.title }
    let duration = formatter.string(from: TimeInterval(item.length / 1000))
    
    print("\(artist!.value) - \"\(title!.value)\" (\(duration))")
}

exit(0)

guard let fileHandle = FileHandle(forReadingAtPath: fileURL.path) else {
    print("can't read file at \(fileURL.path)")
    exit(EXIT_FAILURE)
}

var dataBuffer: Data
dataBuffer = fileHandle.readData(ofLength: 4)
print(String(data: dataBuffer, encoding: .utf8)!) //mhbd

dataBuffer = fileHandle.readData(ofLength: 4)
var offset: UInt64 = UInt64(dataBuffer.parseLEUInt8()!)
print("End of header for mhdb:", offset)

try fileHandle.seek(toOffset: offset)
dataBuffer = fileHandle.readData(ofLength: 4)
print(String(data: dataBuffer, encoding: .utf8)!) // mhsd - list holder

dataBuffer = fileHandle.readData(ofLength: 4)
let endofMHSDHeader = offset + UInt64(dataBuffer.parseLEUInt8()!)
print("End of header for mhsd", endofMHSDHeader)

dataBuffer = fileHandle.readData(ofLength: 4)
let endOfMHSD = offset + UInt64(dataBuffer.parseLEUInt32()!)
print("end of mhsd", endOfMHSD)

// next list holder
offset = endOfMHSD
try fileHandle.seek(toOffset: offset + 4)
let mhsdHeaderSize = UInt64(fileHandle.readData(ofLength: 4).parseLEUInt32()!)
let mhsdTotalLength = UInt64(fileHandle.readData(ofLength: 4).parseLEUInt32()!)

offset += mhsdHeaderSize
try fileHandle.seek(toOffset: offset + 4)
let mhltHeaderSize = UInt64(fileHandle.readData(ofLength: 4).parseLEUInt32()!)
let mhltCount = UInt64(fileHandle.readData(ofLength: 4).parseLEUInt32()!)
print("\(mhltCount) tracks")

offset += mhltHeaderSize
try fileHandle.seek(toOffset: offset)

for i in 0...(mhltCount - 1) {
//    if #available(macOS 10.15.4, *) {
//        print("mhit", try? fileHandle.offset())
//        let headerIdentifier = fileHandle.readData(ofLength: 4)
//        print(String(data: headerIdentifier, encoding: .utf8))
//    }
    try fileHandle.seek(toOffset: offset + 4) // skip header identifier
    let mhitHeaderSize = UInt64(fileHandle.readData(ofLength: 4).parseLEUInt32()!)
    let mhitTotalLength = UInt64(fileHandle.readData(ofLength: 4).parseLEUInt32()!)
    let mhitNumberOfStrings = UInt64(fileHandle.readData(ofLength: 4).parseLEUInt32()!)
    try fileHandle.seek(toOffset: offset + 31)
    let mhitRating = UInt(fileHandle.readData(ofLength: 1).parseLEUInt8()!) / 20
    try fileHandle.seek(toOffset: offset + 80)
    let mhitPlayCount = UInt(fileHandle.readData(ofLength: 4).parseLEUInt32()!)
    let mhitPlayCount2 = UInt(fileHandle.readData(ofLength: 4).parseLEUInt32()!)
    
    let playcountItem = playcountItems[Int(i)]
    
    if (playcountItem.count == 0 && mhitRating == playcountItem.rating) {
        try fileHandle.seek(toOffset: offset + mhitTotalLength)
        offset += mhitTotalLength
        continue
    }

    print("\(mhitNumberOfStrings) r:\(mhitRating)|\(playcountItem.rating) pc1:\(mhitPlayCount) pc2:\(mhitPlayCount2)")

    var contentOffset = offset + mhitHeaderSize
    for j in 0...(mhitNumberOfStrings - 1) {
        var mhodOffset: UInt64? = nil
        
        if #available(macOS 10.15.4, *) {
            mhodOffset = try? fileHandle.offset()
        }
        
        try fileHandle.seek(toOffset: contentOffset + 4) // skip mhod header identifier
        let mhodHeaderLength = UInt64(fileHandle.readData(ofLength: 4).parseLEUInt32()!)
        let mhodTotalLength = UInt64(fileHandle.readData(ofLength: 4).parseLEUInt32()!)
        let mhodType = UInt64(fileHandle.readData(ofLength: 4).parseLEUInt32()!)
        
        var stringOffset: UInt64 = 0
        var mhodLength: UInt64 = 0
        
        if [15, 16].contains(mhodType) {
            mhodLength = mhodTotalLength - mhodHeaderLength - 12
            stringOffset = 24
        } else if mhodType == 17 {
            mhodLength = mhodTotalLength - mhodHeaderLength
            stringOffset = 36
        } else {
            try fileHandle.seek(toOffset: contentOffset + 28) // skip some fields
            mhodLength = UInt64(fileHandle.readData(ofLength: 4).parseLEUInt32()!)
            stringOffset = 40
        }
        
        try fileHandle.seek(toOffset: contentOffset + 40 ) // skip some fields
        let stringData = fileHandle.readData(ofLength: Int(mhodLength))

        if [15, 16].contains(mhodType) {
            print(mhodType, stringOffset as UInt64?, String(data: stringData, encoding: .utf8))
        } else {
            print(mhodType, stringOffset as UInt64?, String(data: stringData, encoding: .utf16LittleEndian))
        }

        contentOffset += mhodTotalLength
    }

    offset += mhitTotalLength
    print("-----------")
}
