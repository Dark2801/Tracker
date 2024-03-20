//
//  Tracker.swift
//  Tracker
//
//  Created by Андрей Мерзликин on 14.03.2024.
//

import UIKit

struct Tracker: Identifiable {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let sked: [WeekDays]?
    let daysCount: Int
    let attach: Bool
    let category: TrackerCategory
    
    init(
        id: UUID = UUID(),
        name: String,
        color: UIColor,
        emoji: String,
        sked: [WeekDays]?,
        daysCount: Int,
        attach: Bool,
        category: TrackerCategory
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.emoji = emoji
        self.sked = sked
        self.daysCount = daysCount
        self.attach = attach
        self.category = category
    }
    
    var data: Data {
        Data(
            name: name,
            color: color,
            emoji: emoji,
            sked: sked,
            daysCount: daysCount,
            attach: attach,
            category: category
        )
    }
}

extension Tracker {
    struct Data {
        var name: String = ""
        var color: UIColor? = nil
        var emoji: String? = nil
        var sked: [WeekDays]? = nil
        var daysCount = 0
        var attach = false
        var category: TrackerCategory? = nil
    }
}
