//
//  File.swift
//  
//
//  Created by Ravil Khusainov on 28.02.2022.
//

import Foundation
import Combine

public extension HTTP {
    
    final class Client {
        public var settings: Settings = .init()
        fileprivate let session: URLSession
        fileprivate let baseURL: String
        fileprivate var storage: Set<AnyCancellable> = []
        
        public init(_ baseURL: String, session: URLSession = .shared) {
            self.baseURL = baseURL
            self.session = session
        }
        
        public func get<Value: Decodable>(_ path: String, queryItems: [URLQueryItem] = []) async throws -> Value {
            let request = try createRequest(.GET, path: path, queryItems: queryItems, body: nil)
            return try await send(request: request)
        }
        
        public func post<Value: Decodable, JSON: Encodable>(_ json: JSON, path: String, queryItems: [URLQueryItem] = []) async throws -> Value {
            let body = try settings.encoder.encode(json)
            let request = try createRequest(.POST, path: path, queryItems: queryItems, body: body)
            return try await send(request: request)
        }
        
        public func put<Value: Decodable, JSON: Encodable>(_ json: JSON, path: String, queryItems: [URLQueryItem] = []) async throws -> Value {
            let body = try settings.encoder.encode(json)
            let request = try createRequest(.PUT, path: path, queryItems: queryItems, body: body)
            return try await send(request: request)
        }
        
        public func patch<Value: Decodable, JSON: Encodable>(_ json: JSON, path: String, queryItems: [URLQueryItem] = []) async throws -> Value {
            let body = try settings.encoder.encode(json)
            let request = try createRequest(.PATCH, path: path, queryItems: queryItems, body: body)
            return try await send(request: request)
        }
        
        public func delete<Value: Decodable, JSON: Encodable>(_ json: JSON, path: String, queryItems: [URLQueryItem] = []) async throws -> Value {
            let body = try settings.encoder.encode(json)
            let request = try createRequest(.DELETE, path: path, queryItems: queryItems, body: body)
            return try await send(request: request)
        }
        
        private func send<Value: Decodable>(request: URLRequest) async throws -> Value {
            if #available(iOS 15.0, macOS 12.0, *) {
                let (data, response) = try await session.data(for: request)
                #if DEBUG
                log(request: request, response: response, data: data)
                #endif
                return try settings.decoder.decode(Value.self, from: data)
            } else {
               return try await withCheckedThrowingContinuation { continuation in
                    session.dataTaskPublisher(for: request)
                        .sink { completion in
                            switch completion {
                            case .failure(let error):
                                continuation.resume(with: .failure(error))
                            default:
                                break
                            }
                        } receiveValue: { [unowned self] data, response in
                            #if DEBUG
                            self.log(request: request, response: response, data: data)
                            #endif
                            do {
                                let value = try self.settings.decoder.decode(Value.self, from: data)
                                continuation.resume(with: .success(value))
                            } catch {
                                continuation.resume(with: .failure(error))
                            }
                        }
                        .store(in: &storage)
                }
            }
        }
        
        private func createRequest(_ method: Method, path: String, queryItems: [URLQueryItem], body: Data?) throws -> URLRequest {
            guard var components = URLComponents(string: baseURL) else { throw Failure.invalid(url: baseURL) }
            components.path = "/" + path
            components.queryItems = queryItems.isEmpty ? nil : queryItems
            guard let url = components.url else { throw Failure.invalid(url: baseURL) }
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            request.httpBody = body
            for (key, value) in settings.headers {
                request.addValue(value, forHTTPHeaderField: key.rawValue)
            }
            if let count = body?.count {
                request.addValue("\(count)", forHTTPHeaderField: "Content-Length")
            }
            return request
        }
        
        private func log(request: URLRequest, response: URLResponse, data: Data?) {
            if let data = request.httpBody, let str = String(prettyPrint: data) {
                print(str)
            }
            if let method = request.httpMethod, let endpoint = request.url?.absoluteString {
                print(method, endpoint)
            }
            if let resp = response as? HTTPURLResponse {
                print("status code:", resp.statusCode)
            }
            if let data = data, let str = String(prettyPrint: data) {
                print("response body:", str)
            } else if let data = data, let str = String(data: data, encoding: .utf8) {
                print("response body:", str)
            }
        }
    }
}
