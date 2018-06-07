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

    static func convertRepeatToString(_ repeatWeekdays: [String: Bool]) -> String{
        var string = ""
        var count = 0
        for day in repeatWeekdays {
            if day.value {
                switch day.key {
                case "Sunday":
                    string += " Sun"
                    count += 1
                case "Monday":
                    string += " Mon"
                    count += 2
                case "Tuesday":
                    string += " Tue"
                    count += 4
                case "Wednesday":
                    string += " Wed"
                    count += 8
                case "Thursday":
                    string += " Thu"
                    count += 16
                case "Friday":
                    string += " Fri"
                    count += 32
                case "Saturday":
                    string += " Sat"
                    count += 64
                default:
                    break
                }
            }
        }

        switch count {
        case 1, 2, 4, 8, 16, 32, 64:
            string = "Every" + string
        case 127:
            string = "Everyday"
        case 65:
            string = "Every weekend"
        default:
            if !string.isEmpty {
                string.removeFirst()
            }
            break
        }

        return string
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
        return Calendar.current.date(from: components)!
    }

    static func randomString(length: Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)

        var randomString = ""

        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }

        return randomString
    }

    static func randomInt(_ max: Int = Int(UInt32.max)) -> Int {
        return Int(arc4random_uniform(UInt32(max)))
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
    func addMinutes(_ minutes: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }

    func addHours(_ hours: Int) -> Date {
        return Calendar.current.date(byAdding: .hour, value: hours, to: self)!
    }
}
