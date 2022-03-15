

import Foundation

public struct Multipart {
    public let data: Data
    public let mimeType: MimeType
    public let params: [String: String]
    public let filename: String
    public let boundary: String
    
    public init(data: Data,
                mimeType: MimeType = .imageJpg,
                params: [String: String] = [:],
                filename: String = UUID().uuidString.lowercased(),
                boundary: String = UUID().uuidString) {
        self.data = data
        self.mimeType = mimeType
        self.params = params
        self.filename = filename
        self.boundary = "Boundary-" + boundary
    }
    
    public enum MimeType: String {
        case imageJpg = "image/jpg"
    }
}
