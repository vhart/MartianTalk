import Foundation

enum DecodingStrategy {
    case json
    case plist

    func decode(data: Data) -> Any? {
        switch self {
        case .json:
            return try? JSONSerialization.jsonObject(with: data, options: [])
        case .plist:
            return try? PropertyListSerialization.propertyList(from: data, options: [], format: nil)
        }
    }
}
