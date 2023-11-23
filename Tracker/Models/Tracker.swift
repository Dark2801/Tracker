//
//  Tracker.swift
//  Tracker
//
//  Created by Андрей Мерзликин on 16.11.2023.
//

import UIKit

struct Tracker {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: [Weekday]?
}
