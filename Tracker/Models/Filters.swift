//
//  Filters.swift
//  Tracker
//
//  Created by Андрей Мерзликин on 02.03.2024.
//

import Foundation

enum Filters: String, CaseIterable, Codable  {
    case allTrackers = "All trackers"
    case todayTrackers = "Trackers for today"
    case completedTrackers = "Completed"
    case unCompletedTrackers = "Not completed"
    
    var fullName: String {
        switch self {
        case .allTrackers:
            return NSLocalizedString("allTrackers", comment: "")
        case .todayTrackers:
            return NSLocalizedString("todayTrackers", comment: "")
        case .completedTrackers:
            return NSLocalizedString("completedTrackers", comment: "")
        case .unCompletedTrackers:
            return NSLocalizedString("unCompletedTrackers", comment: "")
        }
    }
}
