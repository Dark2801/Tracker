//
//  Tracker.swift
//  Tracker
//
//  Created by Андрей Мерзликин on 02.03.2024.
//

import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [TrackerSchedule.DaysOfTheWeek]?
    let pinned: Bool
    let colorIndex: Int
    var isCompleted: Bool
    
    init(
        id: UUID,
        name: String,
        color: UIColor,
        emoji: String,
        schedule: [TrackerSchedule.DaysOfTheWeek]? = nil,
        pinned: Bool,
        colorIndex: Int,
        isCompleted: Bool
        
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
        self.pinned = pinned
        self.colorIndex = colorIndex
        self.isCompleted = isCompleted
    }
}
