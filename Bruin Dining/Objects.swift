//
//  Objects.swift
//  Bruin Dining
//
//  Created by Marius Genton on 1/8/23.
//

import Foundation

struct OpenRestaurant: Hashable {
    let name: String
    let closingTime: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(closingTime)
    }
}

struct DailyDiningHours {
    let day: Date
    let hours: [Restaurant]
    
    init(day: Date, hours: [Restaurant]) {
        self.day = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: day) ?? Date()
        self.hours = hours
    }
    
    func nextTimelineDate() -> Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: day) ?? Date()
    }
    
    func timelineUpdateDates() -> [Date] {
        var updateDates = Set<Date>()
        updateDates.insert(Date())
        for restaurant in hours {
            for meal in restaurant.meals {
                if let openDate = meal.open.toDate(day: day) {
                    updateDates.insert(openDate)
                }
                if let closeDate = meal.close.toDate(day: day) {
                    updateDates.insert(closeDate)
                }
            }
        }
        return Array(updateDates).sorted()
    }
    
    func open(_ date: Date) -> [OpenRestaurant] {
        let time = date.time()
        var openRestaurants = [OpenRestaurant]()
        for restaurant in hours {
            let isOpen = restaurant.isOpen(time: time)
            if isOpen != nil {
                openRestaurants.append(OpenRestaurant(name: restaurant.name, closingTime: isOpen!.description))
            }
        }
        openRestaurants.sort { r1, r2 in r1.closingTime < r2.closingTime }
        return openRestaurants
    }
    
    func nextMeal(_ date: Date) -> String {
        let time = date.time()
        var firstOpeningTime: Time?
        var nextMealName: String?
        for restaurant in hours {
            if let next = restaurant.nextMeal(time: time) {
                if firstOpeningTime == nil || next.1 < firstOpeningTime! {
                    firstOpeningTime = next.1
                    nextMealName = next.0
                }
            }
        }
        if firstOpeningTime != nil {
            return nextMealName! + " opens at " + firstOpeningTime!.description
        }
        return "All closed for the day 😔"
    }
}

struct Restaurant {
    let name: String
    let meals: [Meal]
    
    func isOpen(time: Time) -> Time? {
        for meal in meals {
            if meal.isOpen(time: time) != nil { return meal.isOpen(time: time) }
        }
        return nil
    }
    
    func nextMeal(time: Time) -> (String, Time)? {
        var next: Meal?
        for meal in meals {
            if meal.open > time {
                if next == nil || meal.open < next!.open { next = meal }
            }
        }
        if next == nil { return nil }
        else { return (next!.name, next!.open) }
    }
}

struct Time: Hashable, CustomStringConvertible, Comparable {
    static func < (lhs: Time, rhs: Time) -> Bool {
        return (lhs.hours < rhs.hours) || (lhs.hours == rhs.hours && lhs.minutes < rhs.minutes)
    }
    
    var description: String {
        var hS = String(hours)
        if hours < 10 {
            hS = "0"+hS
        }
        var mS = String(minutes)
        if minutes < 10 {
            mS = "0"+mS
        }
        
        return hS+":"+mS
    }

    let hours: Int
    let minutes: Int
    
    
    func toDate(day: Date) -> Date? {
        guard let date = Calendar.current.date(bySettingHour: hours, minute: minutes, second: 0, of: day) else {
            return nil
        }
        return date
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(hours)
        hasher.combine(minutes)
    }
}

struct Meal {
    let name: String
    let open: Time
    let close: Time
    
    func isOpen(time: Time) -> Time? {
        // Check if has opened yet
        if (open.hours > time.hours) || (open.hours == time.hours && open.minutes > time.minutes) {
            return nil
        }
        
        // Check if has closed yet
        if (close.hours < time.hours) || (close.hours == time.hours && close.minutes <= time.minutes) {
            return nil
        }
        return close
    }
}

extension Date {
    func time() -> Time {
        let calendar = Calendar.current
        let t = Time(hours: calendar.component(.hour, from: self), minutes: calendar.component(.minute, from: self))
        return t
    }
}
