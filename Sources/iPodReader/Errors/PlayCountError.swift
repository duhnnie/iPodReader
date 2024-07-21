import Foundation

internal enum PlayCountError: Error {
    case NoDatabaseData
}

extension PlayCountError: LocalizedError {
    var errorDescription: String? {
        switch (self) {
        case .NoDatabaseData:
            return "No track dataset found on provided database"
        }
    }
}
