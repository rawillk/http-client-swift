//
//  File.swift
//  
//
//  Created by Ravil Khusainov on 28.02.2022.
//

import Foundation


public enum HTTP {
    
    public enum Method: String {
        case GET
        case POST
        case PUT
        case PATCH
        case DELETE
        case OPTIONS
    }
    
    public enum Header: String {
        case contentType = "Content-Type"
        case accept = "Accept"
        case authorization = "Authorization"
        case userAgent = "User-Agent"
    }
    
    public enum Failure: Error {
        case invalid(url: String)
    }
    
    public struct Settings {
        public var decoder: JSONDecoder = .init()
        public var encoder: JSONEncoder = .init()
        public var headers: [Header: String] = [
            .accept: "application/json",
            .contentType: "application/json"
        ]
        public var authorization: Authorization? {
            set {
                if let value = newValue {
                    headers[.authorization] = value.value
                } else {
                    headers.removeValue(forKey: .authorization)
                }
            }
            get {
                if let val = headers[.authorization] {
                    return .custom(value: val)
                } else {
                    return nil
                }
            }
        }
    }
    
    public enum Authorization {
        case bearer(token: String)
        case basic(username: String, password: String)
        case custom(value: String)
        
        var value: String {
            switch self {
            case .bearer(let token):
                return "Bearer " + token
            case .basic(let username, let password):
                return username + ":" + password
            case .custom(let val):
                return val
            }
        }
    }
}
