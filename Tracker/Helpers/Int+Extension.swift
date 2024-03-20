//
//  Int+Extension.swift
//  Tracker
//
//  Created by Андрей Мерзликин on 14.03.2024.
//

import Foundation

extension Int {
    
    // MARK: - Word Declension Method
        func daysString() -> String {
            if self == 0 {
                        return "\(self) дней"
                    }

            let absValue = abs(self)
            
            let lastTwoDigits = absValue % 100
            
            if lastTwoDigits >= 11 && lastTwoDigits <= 19 {
                return "\(self) дней"
            } else {
                let lastDigit = absValue % 10
                
                switch lastDigit {
                case 1:
                    return "\(self) день"
                case 2, 3, 4:
                    return "\(self) дня"
                default:
                    return "\(self) дней"
                }
            }
        }
}
