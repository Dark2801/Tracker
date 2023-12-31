//
//  UserDefaultsManager.swift
//  Tracker
//
//  Created by Андрей Мерзликин on 25.12.2023.
//

import Foundation

@propertyWrapper
struct Defaults<T> {
    let key: String
    var storage: UserDefaults = .standard
    
    var wrappedValue: T? {
        get {
            return storage.value(forKey: key) as? T
        }
        set {
            storage.setValue(newValue, forKey: key)
        }
    }
}
final class UserDefaultsManager {
    @Defaults<Bool>(key: "showIrregularEvent") static var showIrregularEvent
    @Defaults<Bool>(key: "totalTimesLaunching") static var totalTimesLaunching
    @Defaults<[String]>(key: "categoriesArray") static var categoriesArray
    @Defaults<[String]>(key: "timetableArray") static var timetableArray
    @Defaults<Int>(key: "editingIndexPath") static var editingIndexPath
}
