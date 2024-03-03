//
//  SheduleViewCell.swift
//  Tracker
//
//  Created by Андрей Мерзликин on 03.03.2024.
//

import UIKit

final class ScheduleViewCell: UITableViewCell {
    
    var selectedDay: Bool = false
    
    private lazy var weekDay: UILabel = {
        let dayOfWeek = UILabel()
        dayOfWeek.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        dayOfWeek.translatesAutoresizingMaskIntoConstraints = false
        return dayOfWeek
    }()
    
    private lazy var switchDay: UISwitch = {
        let switchDay = UISwitch()
        switchDay.onTintColor = UIColor.ypBlue
        switchDay.translatesAutoresizingMaskIntoConstraints = false
        switchDay.addTarget(self, action: #selector(switchWasTapped), for: .touchUpInside)
        return switchDay
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .ypBackgroundDay
        clipsToBounds = true
        
        contentView.addSubview(weekDay)
        addSubview(switchDay)
        
        NSLayoutConstraint.activate([
            weekDay.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            weekDay.centerYAnchor.constraint(equalTo: centerYAnchor),
            switchDay.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            switchDay.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    @objc private func switchWasTapped(_ sender: UISwitch) {
        self.selectedDay = sender.isOn
    }
    
    func update(with title: String) {
        weekDay.text = title
    }
}
