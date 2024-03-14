//
//  String+Extension.swift
//  Tracker
//
//  Created by Андрей Мерзликин on 14.03.2024.
//

import Foundation

extension String {
    
    var localized: String {
        NSLocalizedString(
            self,
            comment: "\(self) could not be found in Localizable.strings"
        )
    }
}
