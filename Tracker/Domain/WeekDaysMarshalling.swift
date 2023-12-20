//
//  WeekdaysMarshalling.swift
//  Tracker
//
//  Created by Андрей Мерзликин on 20.12.2023.
//

import Foundation

final class WeekDaysMarshalling {
    private let weekDays: [String] = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
    
    func makeStringFromArray(_ timetable: [String]) -> String {
        var string = ""
        for day in weekDays {
            if timetable.contains(day) {
                string += "1"
            } else {
                string += "0"
            }
        }
        return string
    }
    
    func makeWeekDayArrayFromString(_ timetable: String?) -> [String] {
        var array: [String] = []
        if let timetable = timetable {
            timetable.enumerated().forEach { index, character in
                if character == "1" {
                    array.append(weekDays[index])
                }
            }
        }
        
        return array
    }
}
