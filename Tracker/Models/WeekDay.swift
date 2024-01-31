//
//  WeekDay.swift
//  Tracker
//
//  Created by Андрей Мерзликин on 08.01.2024.
//

import Foundation

enum WeekDays: String, CaseIterable {
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
    case sunday = "Sunday"
    
    func localize() -> String {
        return self.rawValue.localised()
    }
    static let numberOfDays = WeekDays.allCases.count
}
