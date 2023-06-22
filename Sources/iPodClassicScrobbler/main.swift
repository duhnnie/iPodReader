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

// try fileHandle.seek(toOffset: 4)
dataBuffer = fileHandle.readData(ofLength: 4)
var offset: UInt64 = UInt64(dataBuffer.parseLEUInt8()!)
print(offset)

try fileHandle.seek(toOffset: offset)
dataBuffer = fileHandle.readData(ofLength: 4)
print(String(data: dataBuffer, encoding: .utf8)!) // mhsd

// try fileHandle.seek(toOffset: 4)
dataBuffer = fileHandle.readData(ofLength: 4)
offset += UInt64(dataBuffer.parseLEUInt8()!)

try fileHandle.seek(toOffset: offset)
dataBuffer = fileHandle.readData(ofLength: 4)
print(String(data: dataBuffer, encoding: .utf8)!) // mhla

dataBuffer = fileHandle.readData(ofLength: 4)
offset += UInt64(dataBuffer.parseLEUInt8()!)

try fileHandle.seek(toOffset: offset)
dataBuffer = fileHandle.readData(ofLength: 4)
print(String(data: dataBuffer, encoding: .utf8)!) // mhia

dataBuffer = fileHandle.readData(ofLength: 4)
offset += UInt64(dataBuffer.parseLEUInt8()!)

try fileHandle.seek(toOffset: offset)
dataBuffer = fileHandle.readData(ofLength: 4)
print(String(data: dataBuffer, encoding: .utf8)!)

try fileHandle.seek(toOffset: offset + 28)
let dataLength = UInt64(fileHandle.readData(ofLength: 4).parseLEUInt8()!)
try fileHandle.seek(toOffset: offset + 40)
let data = fileHandle.readData(ofLength: Int(dataLength))
print(String(data: data, encoding: .utf16LittleEndian)!)

// try fileHandle.seek(toOffset: UInt64(offset))
// dataBuffer = fileHandle.readData(ofLength: 4)
// print(String(data: dataBuffer, encoding: .utf8)!)



// try fileHandle.seek(toOffset: 8)
// dataBuffer = fileHandle.readData(ofLength: 4)
// print(String(data: dataBuffer, encoding: .utf8))





//if let fileURL = Bundle.module.url(forResource: "Resources/lyrics", withExtension: "txt") {
//    let fileHandle = FileHandle(forReadingAtPath: fileURL.path)
//
//    if let fileHandle = fileHandle {
//        var dataBuffer: Data
//
//        print("Offset = \(fileHandle.offsetInFile)")
//        dataBuffer = fileHandle.readData(ofLength: 5)
//        print(String(data: dataBuffer, encoding: .utf8)!)
//
//        fileHandle.seekToEndOfFile()
//        print("Offset = \(fileHandle.offsetInFile)")
//        dataBuffer = fileHandle.readData(ofLength: 5)
//        print(String(data: dataBuffer, encoding: .utf8)!)
//
//        try! fileHandle.seek(toOffset: 30)
//        print("Offset = \(fileHandle.offsetInFile)")
//        dataBuffer = fileHandle.readData(ofLength: 5)
//        print(String(data: dataBuffer, encoding: .utf8)!)
//        fileHandle.closeFile()
//    } else {
//        print("No file")
//    }
//} else {
//    print("Error at trying to get the lyrics")
//}
