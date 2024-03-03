//
//  CategoryCell.swift
//  Tracker
//
//  Created by Андрей Мерзликин on 03.03.2024.
//

import UIKit

final class CategoryCell: UITableViewCell {
    // Reuse identifier
    static let reuseIdentifier = "CategoryCellReuseIdentifier"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    private let doneImage = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        super.init(coder: coder)
        setupUI()
    }
    //MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .ypBackgroundDay
        clipsToBounds = true
        setupConstraints()
    }
    
    private func setupConstraints() {
        [titleLabel, doneImage].forEach {
        addSubview($0)
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            doneImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            doneImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            doneImage.widthAnchor.constraint(equalToConstant: 24),
            doneImage.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    //MARK: Public Methods
    
    func update(with title: String) {
        titleLabel.text = title
    }
    
    func done(with image: UIImage) {
        doneImage.image = image
    }
}
