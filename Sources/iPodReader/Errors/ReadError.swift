import Foundation

internal enum ReadError: Error {
    case NoElementMatchError(expected: String)
    case ParseHeaderFieldError(field: String)
    case EnumParseError(type: String)
    case ElementNotFoundAtIndex(index: UInt64)
}

extension ReadError: LocalizedError {
    var errorDescription: String? {
        switch (self) {
        case .NoElementMatchError(expected: let expected):
            let format = NSLocalizedString("No element match, \"%@\" expected.", comment: "")
            
            return String(format: format, expected)
        case .EnumParseError(type: let type):
            let format = NSLocalizedString("Can't parse to enum \"%@\"", comment: "")
            
            return String(format: format, type)
        case .ParseHeaderFieldError(field: let field):
            let format = NSLocalizedString("Can't parse header field \"%@\"", comment: "")
            
            return String(format: format, field)
        case .ElementNotFoundAtIndex(index: let index):
            let format = NSLocalizedString("No element at index \"%@\".", comment: "")
            
            return String(format: format, index)
        }
    }
}
