//
//  StatisticsCell.swift
//  Tracker
//
//  Created by Андрей Мерзликин on 05.03.2024.
//

import UIKit

final class StatisticsCell: UITableViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private let countLabel: UILabel = {
        let countLabel = UILabel()
        countLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        return countLabel
    }()
    
    private let borderView: UIView = {
        let borderView = UIView()
        borderView.layer.cornerRadius = 16
        borderView.backgroundColor = .ypBlue
        return borderView
    }()
    
    private let gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.ypColorSelection1.cgColor, UIColor.ypColorSelection9.cgColor, UIColor.ypColorSelection3.cgColor]
        gradientLayer.locations = [0, 0.5, 1]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.cornerRadius = 16
        return gradientLayer
    }()
    
    private let insideView: UIView = {
        let insideView = UIView()
        insideView.layer.cornerRadius = 16
        insideView.backgroundColor = .ypWhiteDay
        return insideView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        clipsToBounds = true
        addSubViews()
        applyConstraints()
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = borderView.bounds
    }
    
    func update(with title: String, count: String) {
        titleLabel.text = title
        countLabel.text = count
    }
    
    private func addSubViews() {
        [borderView, insideView, countLabel, titleLabel].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        borderView.layer.addSublayer(gradientLayer)
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            borderView.centerYAnchor.constraint(equalTo: centerYAnchor),
            borderView.centerXAnchor.constraint(equalTo: centerXAnchor),
            borderView.leadingAnchor.constraint(equalTo: leadingAnchor),
            borderView.trailingAnchor.constraint(equalTo: trailingAnchor),
            borderView.heightAnchor.constraint(equalToConstant: 90),
            insideView.leadingAnchor.constraint(equalTo: borderView.leadingAnchor, constant: 1),
            insideView.trailingAnchor.constraint(equalTo: borderView.trailingAnchor, constant: -1),
            insideView.topAnchor.constraint(equalTo: borderView.topAnchor, constant: 1),
            insideView.bottomAnchor.constraint(equalTo: borderView.bottomAnchor, constant: -1),
            countLabel.leadingAnchor.constraint(equalTo: insideView.leadingAnchor, constant: 12),
            countLabel.topAnchor.constraint(equalTo: insideView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: insideView.leadingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: countLabel.bottomAnchor, constant: 7)
        ])
    }
}

