// Based on post on https://developer.apple.com/forums/thread/652469
import Foundation

internal extension Data {
  func parseLEUIntX<Result>(_: Result.Type) -> Result? where Result: UnsignedInteger {
    let expected = MemoryLayout<Result>.size
    guard self.count >= expected else { return nil }
    // defer { self = self.dropFirst(expected) }

    return self
      .prefix(expected)
      .reversed()
      .reduce(0, { soFar, new in
        (soFar << 8) | Result(new)
      })
  }

  func parseLEUInt8() -> UInt8? {
    parseLEUIntX(UInt8.self)
  }

  func parseLEUInt16() -> UInt16? {
    parseLEUIntX(UInt16.self)
  }

  func parseLEUInt32() -> UInt32? {
    parseLEUIntX(UInt32.self)
  }

  func parseLEUInt64() -> UInt64? {
    parseLEUIntX(UInt64.self)
  }
}
