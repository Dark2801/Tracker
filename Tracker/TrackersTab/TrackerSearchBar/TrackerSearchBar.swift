//
//  TrackerSearchBar.swift
//  Tracker
//
//  Created by Андрей Мерзликин on 16.11.2023.
//

import UIKit

// MARK: - Tracker SearchBar Class

final class TrackerSearchBar: UISearchBar {
    
// MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.searchBarStyle = .minimal
        self.returnKeyType = .go
        self.searchTextField.clearButtonMode = .never
        self.placeholder = "Поиск"
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
