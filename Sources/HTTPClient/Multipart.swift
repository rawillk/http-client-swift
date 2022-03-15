

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


extension Multipart {
    var body: Data {
        let body = NSMutableData()
        
        let boundaryPrefix = "--\(boundary)\r\n"
        
        for (key, value) in params {
            body.appendString(boundaryPrefix)
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }
        
        body.appendString(boundaryPrefix)
        body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimeType.rawValue)\r\n\r\n")
        body.append(data)
        body.appendString("\r\n")
        body.appendString("--".appending(boundary.appending("--")))
        
        return body as Data
    }
}

private extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}

