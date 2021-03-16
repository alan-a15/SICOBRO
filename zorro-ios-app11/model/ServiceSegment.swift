//
//  ServiceSegment.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 19/04/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import Foundation

class ServiceSegment:Decodable {
    
    var id:Int = 0
    var name:String = ""
    var samples:String = ""
    var icon:String = ""
    var enabled:Bool = true
    
    static var JSON_SEGMENTS:[ServiceSegment] = []
    
    static func loadFromLstSegments(segments : [Segment]) -> [ServiceSegment]  {
        var lstServiceSegment : [ServiceSegment] = []
        do {
            try JSON_SEGMENTS = ServiceSegment.fromJsonPath()
        } catch let error {
            print("Error trying to parse ServiceSegment: \(error)")
            JSON_SEGMENTS = []
        }
        segments.forEach { (it) in
            lstServiceSegment.append(ServiceSegment.fromSegment(segment: it))
        }
        return lstServiceSegment
    }
    
    static func fromSegment(segment : Segment) -> ServiceSegment {
        let srv = JSON_SEGMENTS.first { (it) -> Bool in
            it.id == segment.id ?? 0
        }
        guard let serviceSegment = srv else {
            let oserviceSegment = ServiceSegment()
            oserviceSegment.id = segment.id ?? 0
            oserviceSegment.name = segment.name ?? ""
            oserviceSegment.samples = oserviceSegment.samples.uppercased()  // Samples are fixed in JSON
            return oserviceSegment
        }
        serviceSegment.id = segment.id ?? 0
        serviceSegment.name = segment.name ?? ""
        serviceSegment.samples = serviceSegment.samples.uppercased()  // Samples are fixed in JSON
        return serviceSegment
    }
    
    static func fromJsonPath() throws -> [ServiceSegment]  {
        JSON_SEGMENTS = JsonUtils.jsonToObject(fileName: "SegmentTypes", type: [ServiceSegment].self) ?? []
        return JSON_SEGMENTS
    }
    
}
