//
//  TrackerTitleSectionView.swift
//  Tracker
//
//  Created by Андрей Мерзликин on 03.03.2024.
//

import UIKit

final class TrackerTitleSectionView: UICollectionReusableView {
    static let id = "header section"
    var headerText: String? {
        didSet {
            titleLabel.text = headerText
        }
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 19)
        label.textAlignment = .natural
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12)
        ])
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
}
