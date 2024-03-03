//
//  FiltersCell.swift
//  Tracker
//
//  Created by Андрей Мерзликин on 03.03.2024.
//

import UIKit

final class FiltersCell: UITableViewCell {
    
    static let reuseIdentifier = "FiltersCell"
    
    //MARK: - Layout variables
    
    private lazy var cellLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlackDay
        label.font = UIFont.systemFont(ofSize: 17)
        
        return label
    }()
    
    private lazy var selectionImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Checkmark"))
        imageView.isHidden = true
        
        return imageView
    }()
    
    // MARK: - Lifecycle
    
    func configureCell(filter: Filters, isSelected: Bool) {
        cellLabel.text = filter.fullName
        selectionImageView.isHidden = !isSelected
        contentView.backgroundColor = .ypBackgroundDay
        addSubViews()
        setupConstraints()
    }
    
    
    // MARK: - Private Methods
    
    private func addSubViews() {
        [cellLabel, selectionImageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cellLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            cellLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            selectionImageView.heightAnchor.constraint(equalToConstant: 24),
            selectionImageView.widthAnchor.constraint(equalToConstant: 24),
            selectionImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectionImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
    }
}
