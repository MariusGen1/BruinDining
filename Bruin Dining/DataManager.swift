//
//  DataManager.swift
//  Bruin Dining
//
//  Created by Marius Genton on 10/9/22.
//

import Foundation
import SwiftSoup

class DataManager: ObservableObject {
        
    private func getHTML(url: String) -> String? {
        guard let myURL = URL(string: url) else {
            print("Error: \(url) doesn't seem to be a valid URL")
            return nil
        }

        do {
            let myHTMLString = try String(contentsOf: myURL, encoding: .ascii)
            return myHTMLString
        } catch let error {
            print("Error: \(error)")
        }
        return ""
    }
    
    private func convertTimeFormat(s: String) -> Time {
        let ampm = s[s.count-4]
        let S = s.components(separatedBy: " ")[0]
        let a = S.components(separatedBy: ":")
        var minutes = 0
        if a.count > 1 { minutes = Int(a[1])! }
        var hours = Int(a[0])!
        
        if ampm == "a" && hours == 12 {
            hours = 24
        } else if ampm == "p" && hours != 12 {
            hours = 12 + hours
        }
        
        return Time(hours: hours, minutes: minutes)
    }
    
    private func getOpenHours(s: String) -> [Time] {
        let splitS = s.components(separatedBy: " - ")
        return [convertTimeFormat(s: splitS[0]), convertTimeFormat(s: splitS[1])]
    }
    
    func fetchDiningHours() async -> DailyDiningHours {
        do {
            // Download HTML from the website
            let html = getHTML(url: DINING_HOURS_URL)
            
            // Parse to read the opening hours
            let doc = try SwiftSoup.parse(html ?? "")
            
            let dateString = try doc.title().split(separator: " ").suffix(3).joined(separator: " ")
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM d, yyyy"
            let date = dateFormatter.date(from: dateString) ?? Date()
            
            let table = try doc.select("tbody").first()?.select("tr") ?? Elements()
            
            var data = [Restaurant]()
            
            for restaurant in table {
                var restaurantName = try restaurant.select("span").first!.text()
                
                // Shorten some of the names
                for name in SHORTENED_NAMES.keys {
                    if restaurantName == name { restaurantName = SHORTENED_NAMES[name] ?? restaurantName }
                }
                
                var meals = [Meal]()
                for meal in ["Breakfast", "Lunch", "Dinner", "Extended Dinner"] {
                    for elem in try restaurant.select("td") {
                        if try elem.className() == "hours-open " + meal {
                            let hours = try getOpenHours(s: elem.select("span").first!.text())
                            meals.append(Meal(name: meal, open: hours[0], close: hours[1]))
                        }
                    }
                }
                
                data.append(Restaurant(name: restaurantName, meals: meals))
            }
            
            return DailyDiningHours(day: date, hours: data)
        } catch Exception.Error(_, let message) {
            print(message)
        } catch {
            print("error")
        }
        
        return DailyDiningHours(day: Date(), hours: [])
    }
    
    func getUpdateTimes(hours: [Restaurant]) -> [Time] {
        var updateTimes = Set<Time>()
        updateTimes.insert(Date().time())
        
        for restaurant in hours {
            for meal in restaurant.meals {
                updateTimes.insert(meal.open)
                updateTimes.insert(meal.close)
            }
        }
        return Array(updateTimes)
    }
    
    
}


extension StringProtocol {
    subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }
}
