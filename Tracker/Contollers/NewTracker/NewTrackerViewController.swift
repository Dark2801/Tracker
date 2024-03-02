//
//  NewTrackerViewController.swift
//  Tracker
//
//  Created by Андрей Мерзликин on 21.12.2023.
//

import UIKit

final class NewTrackerViewController: UIViewController {
    
    var trackersViewController: TrackersViewController?
    
    private lazy var pageTitleLabel: UILabel = {
        let header = UILabel()
        view.addSubview(header)
        header.translatesAutoresizingMaskIntoConstraints = false
        header.text = "Создание трекера"
        header.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        header.textColor = .ypBlackDay
        return header
    }()
    
    private lazy var createHabitButton: UIButton = {
        let habitButton = UIButton(type: .custom)
        view.addSubview(habitButton)
        habitButton.setTitle("Привычка", for: .normal)
        habitButton.setTitleColor(.ypWhiteDay, for: .normal)
        habitButton.backgroundColor = .ypBlackDay
        habitButton.layer.cornerRadius = 16
        habitButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        habitButton.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside)
        habitButton.translatesAutoresizingMaskIntoConstraints = false
        return habitButton
    }()
    
    private lazy var createIrregularEventButton: UIButton = {
        let irregularButton = UIButton(type: .custom)
        view.addSubview(irregularButton)
        irregularButton.setTitleColor(.ypWhiteDay, for: .normal)
        irregularButton.backgroundColor = .ypBlackDay
        irregularButton.layer.cornerRadius = 16
        irregularButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        irregularButton.setTitle("Нерегулярное событие", for: .normal)
        irregularButton.addTarget(self, action: #selector(irregularButtonTapped), for: .touchUpInside)
        irregularButton.translatesAutoresizingMaskIntoConstraints = false
        return irregularButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhiteDay
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: view.topAnchor),
            view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            pageTitleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 26),
            pageTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            createHabitButton.topAnchor.constraint(equalTo: pageTitleLabel.bottomAnchor, constant: 295),
            createHabitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createHabitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createHabitButton.heightAnchor.constraint(equalToConstant: 60),
            createIrregularEventButton.topAnchor.constraint(equalTo: createHabitButton.bottomAnchor, constant: 16),
            createIrregularEventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createIrregularEventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createIrregularEventButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func habitButtonTapped() {
        let addHabit = NewHabitViewController(edit: false)
        addHabit.trackersViewController = self.trackersViewController
        present(addHabit, animated: true)
    }
    
    @objc private func irregularButtonTapped() {
        let addEvent = IrregularEventViewController()
        addEvent.trackersViewController = self.trackersViewController
        present(addEvent, animated: true)
    }
}

