//
//  String+Extension.swift
//  Tracker
//
//  Created by Андрей Мерзликин on 20.12.2023.
//

import Foundation

extension String {
    func localised() -> String {
        NSLocalizedString(self,
                          tableName: "Localizable",
                          value: self,
                          comment: self)
    }
}
