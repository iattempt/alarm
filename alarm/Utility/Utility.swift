//
//  Utility.swift
//  alarm
//
//  Created by Ernest on 01/06/2018.
//  Copyright © 2018 Ernest. All rights reserved.
//

import Foundation

class Utility {
    init() {
        Utility.dateFormatter.dateFormat = "HH:mm"
    }

    static let dateFormatter = DateFormatter()

    static func sortAlarmByTime(_ alarms: [Alarm]) -> [Alarm]{
        return alarms.stableSorted{ (a, b) -> Bool in
            a.date.timeIntervalSince1970 < b.date.timeIntervalSince1970
        }
    }

    static func unifyDate(_ date: Date ) -> Date {
        // we need to sort date for view therefore always change date to 20180101
        let time = Calendar.current.dateComponents([.hour, .minute], from: date)
        var components = DateComponents()
        components.year = 2018
        components.month = 1
        components.day = 1
        components.hour = time.hour
        components.minute =  time.minute
        components.second = 0
        return Calendar.current.date(from: components)!
    }

    static func randomLowerCase(length: Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyz"
        var randomString = ""

        for _ in 0 ..< length {
            let rand = arc4random_uniform(UInt32(letters.length))
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }

        return randomString
    }

    static func randomUpperCase(length: Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyz"
        var randomString = ""

        for _ in 0 ..< length {
            let rand = arc4random_uniform(UInt32(letters.length))
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }

        return randomString
    }

    static func randomAlpha(length: Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        var randomString = ""

        for _ in 0 ..< length {
            let rand = arc4random_uniform(UInt32(letters.length))
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }

        return randomString
    }

    static func randomAlphaNumber(length: Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString = ""

        for _ in 0 ..< length {
            let rand = arc4random_uniform(UInt32(letters.length))
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }

        return randomString
    }

    static func randomInt(_ max: Int = Int(UInt32.max)) -> Int {
        return Int(arc4random_uniform(UInt32(max)))
    }

    static func randomInt(_ min: Int, _ max: Int) -> Int {
        let diff = max - min
        return min + Int(arc4random_uniform(UInt32(diff)))
    }

    static func randomBool() -> Bool {
        return randomInt() % 2 == 1
    }

    static func binarySearch(_ a: [Alarm], key: Int, range: Range<Int>) -> Int? {
        if range.lowerBound >= range.upperBound {
            return nil
        } else {
            let midIndex = range.lowerBound + (range.upperBound - range.lowerBound) / 2
            if key < a[midIndex].alarmId {
                return binarySearch(a, key: key, range: range.lowerBound ..< midIndex)
            } else if a[midIndex].alarmId < key {
                return binarySearch(a, key: key, range: midIndex + 1 ..< range.upperBound)
            } else {
                return midIndex
            }
        }
    }
}

extension RandomAccessCollection {
    /// return a sorted collection
    /// this use a stable sort algorithm
    ///
    /// - Parameter areInIncreasingOrder: return nil when two element are equal
    /// - Returns: the sorted collection
    public func stableSorted(by areInIncreasingOrder: (Iterator.Element, Iterator.Element) -> Bool?) -> [Iterator.Element] {

        let sorted = self.enumerated().sorted { (one, another) -> Bool in
            if let result = areInIncreasingOrder(one.element, another.element) {
                return result
            } else {
                return one.offset < another.offset
            }
        }
        return sorted.map{ $0.element }
    }
}

extension Date {
    func addSeconds(_ seconds: Int) -> Date {
        return Calendar.current.date(byAdding: .second, value: seconds, to: self)!
    }

    func addMinutes(_ minutes: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }

    func addHours(_ hours: Int) -> Date {
        return Calendar.current.date(byAdding: .hour, value: hours, to: self)!
    }
}


enum Week: Int, Codable {
    case Monday = 1, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday

    static let allRawValues = Week.Monday.rawValue...Week.Sunday.rawValue
    static let allCases = Array(allRawValues.map{ Week(rawValue: $0)! })

    static func convertWeekToInt(_ week: Week) -> Int {
        return week.rawValue % 7 + 1
    }

    static func convertWeekCaseToAbbreviationString(_ week: Week) -> String {
        switch week {
        case .Monday:
            return "Mon"
        case .Tuesday:
            return "Tue"
        case .Wednesday:
            return "Wed"
        case .Thursday:
            return "Thu"
        case .Friday:
            return "Fri"
        case .Saturday:
            return "Sat"
        case .Sunday:
            return "Sun"
        }
    }

    static func convertWeekCaseToString(_ week: Week) -> String {
        switch week {
        case .Monday:
            return "Monday"
        case .Tuesday:
            return "Tuesday"
        case .Wednesday:
            return "Wednesday"
        case .Thursday:
            return "Thursday"
        case .Friday:
            return "Friday"
        case .Saturday:
            return "Saturday"
        case .Sunday:
            return "Sunday"
        }
    }

    static func convertWeekStringToCase(_ string: String) -> Week {
        switch string {
        case "Monday":
            return .Monday
        case "Tuesday":
            return .Tuesday
        case "Wednesday":
            return .Wednesday
        case "Thursday":
            return .Thursday
        case "Friday":
            return .Friday
        case "Saturday":
            return .Saturday
        case "Sunday":
            return .Sunday
        default:
            assert(false)
            return .Monday
        }
    }

    static func convertWeekdaysToStringForDisplaying(_ repeatWeekdays: [Week]) -> String{
        var string = ""
        var count = 0
        for day in repeatWeekdays {
            string += " \(Week.convertWeekCaseToAbbreviationString(day))"
            count += Week.convertWeekToFlagBit(day)
        }

        switch count {
        case 2, 4, 8, 16, 32, 64, 128:
            string = "Every" + string
        case 255:
            string = "Everyday"
        case 192:
            string = "Weekends"
        default:
            if !string.isEmpty {
                string.removeFirst()
            }
            break
        }

        return string
    }

    private static func convertWeekToFlagBit(_ week: Week) -> Int {
        return Int(pow(Double(2.0), Double(week.rawValue)))
    }
}
