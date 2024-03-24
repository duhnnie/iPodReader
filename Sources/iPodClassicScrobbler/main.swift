import Foundation

print("Hello, world!")

//guard var fileURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
//    exit(EXIT_FAILURE)
//}

var fileURL = URL(fileURLWithPath: "/users/daniel/Documents", isDirectory: true)

fileURL.appendPathComponent("iPodReaderProject", isDirectory: true)
fileURL.appendPathComponent("iTunesDB", isDirectory: false)

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

offset = endofMHSDHeader

try fileHandle.seek(toOffset: offset)
dataBuffer = fileHandle.readData(ofLength: 4)
print(String(data: dataBuffer, encoding: .utf8)!) // mhla - album item

dataBuffer = fileHandle.readData(ofLength: 4)
offset += UInt64(dataBuffer.parseLEUInt8()!)
print("End of header for mhla", offset)

try fileHandle.seek(toOffset: offset)
dataBuffer = fileHandle.readData(ofLength: 4)
print(String(data: dataBuffer, encoding: .utf8)!) // mhia - album item

dataBuffer = fileHandle.readData(ofLength: 4)
let endOfHeader = offset + UInt64(dataBuffer.parseLEUInt8()!)
print("End of header for mhia", endOfHeader)
try fileHandle.seek(toOffset: offset + 12)
dataBuffer = fileHandle.readData(ofLength: 4)
print("number of strings in mhia", UInt(dataBuffer.parseLEUInt32()!))
offset = endOfHeader

try fileHandle.seek(toOffset: offset)
dataBuffer = fileHandle.readData(ofLength: 4)
print(String(data: dataBuffer, encoding: .utf8)!) // mhod - string holder

try fileHandle.seek(toOffset: offset + 4)
print("End of header for mhod", offset + UInt64(fileHandle.readData(ofLength: 4).parseLEUInt8()!))

try fileHandle.seek(toOffset: offset + 8)
var totalLength = UInt64(fileHandle.readData(ofLength: 4).parseLEUInt8()!)
print("Size of mhod", totalLength)
print("end of mhod", offset + totalLength)
try fileHandle.seek(toOffset: offset + 28)
var dataLength = UInt64(fileHandle.readData(ofLength: 4).parseLEUInt8()!)
try fileHandle.seek(toOffset: offset + 40)
var data = fileHandle.readData(ofLength: Int(dataLength))
print(String(data: data, encoding: .utf16LittleEndian)!)
offset += totalLength;

// ---- mhod
try fileHandle.seek(toOffset: offset)
dataBuffer = fileHandle.readData(ofLength: 4)
print(">", String(data: dataBuffer, encoding: .utf8)!) // mhod

try fileHandle.seek(toOffset: offset + 8)
totalLength = UInt64(fileHandle.readData(ofLength: 4).parseLEUInt8()!)
try fileHandle.seek(toOffset: offset + 28)
dataLength = UInt64(fileHandle.readData(ofLength: 4).parseLEUInt8()!)
try fileHandle.seek(toOffset: offset + 40)
data = fileHandle.readData(ofLength: Int(dataLength))
print(String(data: data, encoding: .utf16LittleEndian)!)
offset += totalLength;

try fileHandle.seek(toOffset: offset)
dataBuffer = fileHandle.readData(ofLength: 4)
print(">", String(data: dataBuffer, encoding: .utf8)!) // mhod

try fileHandle.seek(toOffset: offset + 8)
totalLength = UInt64(fileHandle.readData(ofLength: 4).parseLEUInt8()!)
try fileHandle.seek(toOffset: offset + 28)
dataLength = UInt64(fileHandle.readData(ofLength: 4).parseLEUInt8()!)
try fileHandle.seek(toOffset: offset + 40)
data = fileHandle.readData(ofLength: Int(dataLength))
print(String(data: data, encoding: .utf16LittleEndian)!)
offset += totalLength;

try fileHandle.seek(toOffset: offset)
dataBuffer = fileHandle.readData(ofLength: 4)
print(String(data: dataBuffer, encoding: .utf8)!)
print("--------")

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

for i in 0...(mhltCount - 1) {
    if #available(macOS 10.15.4, *) {
        print("mhit", try? fileHandle.offset())
        let headerIdentifier = fileHandle.readData(ofLength: 4)
        print(String(data: headerIdentifier, encoding: .utf8))
    }
    try fileHandle.seek(toOffset: offset + 4) // skip header identifier
    let mhitHeaderSize = UInt64(fileHandle.readData(ofLength: 4).parseLEUInt32()!)
    let mhitTotalLength = UInt64(fileHandle.readData(ofLength: 4).parseLEUInt32()!)
    let mhitNumberOfStrings = UInt64(fileHandle.readData(ofLength: 4).parseLEUInt32()!)
    try fileHandle.seek(toOffset: offset + 80)
    let mhitPlayCount = UInt(fileHandle.readData(ofLength: 4).parseLEUInt32()!)
    let mhitPlayCount2 = UInt(fileHandle.readData(ofLength: 4).parseLEUInt32()!)

    print("\(mhitNumberOfStrings) \(mhitPlayCount) \(mhitPlayCount2)")

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
