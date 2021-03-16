//
//  JsonUtils.swift
//  zorro-ios-app1
//
//  Created by José Antonio Hijar on 3/16/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import Foundation

struct JsonUtils {
    static func readJSONFromFile(fileName: String) -> Any? {
        var json: Any?
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            do {
                let fileUrl = URL(fileURLWithPath: path)
                // Getting data from JSON file using the file URL
                let data = try Data(contentsOf: fileUrl, options: .mappedIfSafe)
                json = try? JSONSerialization.jsonObject(with: data)
            } catch {
                // Handle error here
            }
        }
        return json
    }
    
    static func jsonToObject<T: Decodable>(fileName: String, type: T.Type) -> T?{
        var object : T?
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            do {
                let fileUrl = URL(fileURLWithPath: path)
                let data = try Data(contentsOf: fileUrl, options: .mappedIfSafe)
                
                let jsonDecoder = JSONDecoder()
                object = try jsonDecoder.decode(type, from: data)
            } catch let error {
                // Handle error here
                print("An error ocurred on jsonToObject [\(error)]")
            }
        }
        return object
    }
}
