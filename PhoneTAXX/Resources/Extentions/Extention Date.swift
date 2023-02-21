//
//  Extention Date.swift
//  PhoneTAXX
//
//  Created by SMIT 005 on 27/05/21.
//

import Foundation

extension Date {
    var startOfWeek: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 0, to: sunday)
    }

    var endOfWeek: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 6, to: sunday)
    }
    
    init?(jsonDate: String) {
        let prefix = "/Date("
        let suffix = ")/"
        let scanner = Scanner(string: jsonDate)

        // Check prefix:
        if scanner.scanString(prefix, into: nil) {

            // Read milliseconds part:
            var milliseconds : Int64 = 0
            if scanner.scanInt64(&milliseconds) {
                // Milliseconds to seconds:
                var timeStamp = TimeInterval(milliseconds)///1000.0

                // Read optional timezone part:
                var timeZoneOffset : Int = 0
                if scanner.scanInt(&timeZoneOffset) {
                    let hours = timeZoneOffset / 100
                    let minutes = timeZoneOffset % 100
                    // Adjust timestamp according to timezone:
                    timeStamp += TimeInterval(3600 * hours + 60 * minutes)
                }

                // Check suffix:
                if scanner.scanString(suffix, into: nil) {
                    // Success! Create NSDate and return.
                    self.init(timeIntervalSince1970: timeStamp)
                    return
                }
            }
        }

        // Wrong format, return nil. (The compiler requires us to
        // do an initialization first.)
        self.init(timeIntervalSince1970: 0)
        return nil
    }
}

// code to use date extention for converting timestamp into dateString
//if let theDate = Date(jsonDate: "/Date(1622138536)/") {
//    print(theDate)
//} else {
//    print("wrong format")
//}
