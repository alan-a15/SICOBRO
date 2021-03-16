//
//  PageableRequest.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 14/04/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import Foundation

enum DirectionEnum : String, CaseIterable {
    case ASC  = "De antiguo a reciente."
    case DESC = "De reciente a antiguo."
    
    static var values: [String] {
      return DirectionEnum.allCases.map { $0.rawValue }
    }
}

class PageableRequest {
    
    var startDate: Date? = nil
    var endDate: Date? = nil
    var page: Int = 0
    var pageSize:Int = 0
    var status : String?
    var direction : DirectionEnum = .DESC

    private let ENDPOINT_FORMAT = "ddMMyyyy"
    private var FORMATTER:DateFormatter = DateFormatter() {
        didSet {
            FORMATTER.dateFormat = ENDPOINT_FORMAT
        }
    }
    
    func getStatusString() -> String  {
        guard let status = status, !status.isEmpty else {
            return "ALL"
        }
        return status
    }

    func formatStartDate() -> String {
        return formatDate(date: startDate)
    }

    func formatEndDate() -> String {
        return formatDate(date: endDate)
    }

    private func formatDate(date : Date?) -> String {
        guard let cdate = date else {
            return ""
        }
        
        //var cdate:Date = Calendar.current.date(from: date)!
        FORMATTER.dateFormat = ENDPOINT_FORMAT
        return FORMATTER.string(from: cdate)
    }
    
}
