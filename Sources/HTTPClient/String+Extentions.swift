//
//  File.swift
//  
//
//  Created by Ravil Khusainov on 28.02.2022.
//

import Foundation

extension String {
    init?(prettyPrint: Data) {
        if let json = try? JSONSerialization.jsonObject(with: prettyPrint, options: .mutableContainers) {
            if let prettyPrintedData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
                self.init(data: prettyPrintedData, encoding: .utf8)
                return
            }
        }
        return nil
    }
}
