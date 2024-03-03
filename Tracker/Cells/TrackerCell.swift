//
//  TrackerCell.swift
//  Tracker
//
//  Created by Андрей Мерзликин on 03.03.2024.
//

import UIKit

protocol TrackerCellDelegate: AnyObject {
    func completeTracker(id: UUID, at indexPath: IndexPath)
    func incompleteTracker(id: UUID, at indexPath: IndexPath)
}

final class TrackerCell: UICollectionViewCell {
    
    //MARK: - Properties
    private lazy var cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel ()
        label.backgroundColor = .ypEmojiBackground
        label.clipsToBounds = true
        label.layer.cornerRadius = 24 / 2
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var taskTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypWhiteDay
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.preferredMaxLayoutWidth = 143
        label.frame = CGRect(x: 120, y: 106, width: 143, height: 34)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var daysLabel: UILabel = {
        let label = UILabel ()
        label.textColor = .ypBlackDay
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.frame = CGRect(x: 120, y: 106, width: 101, height: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        let pointSize = UIImage.SymbolConfiguration(pointSize: 11)
        let image = plusImage
        button.tintColor = .ypWhiteDay
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 34 / 2
        button.addTarget(self, action: #selector(didAddButtonTapped),
                         for: .touchUpInside)
        return button
    }()
    
    weak var delegate: TrackerCellDelegate?
    static var reuseId = "cell"
    
    private var isCompletedToday: Bool = false
    private var trackerId: UUID?
    private var indexPath: IndexPath?
    private let analytics = AnalyticsService.shared
    
    //MARK: - Helpers
    
    func configure(
        with tracker: Tracker,
        isCompletedToday: Bool,
        completedDays: Int,
        indexPath: IndexPath
    ) {
        self.trackerId = tracker.id
        self.isCompletedToday = isCompletedToday
        self.indexPath = indexPath
        
        addElements()
        setupConstraints()
        self.cardView.backgroundColor = tracker.color
        self.addButton.backgroundColor = tracker.color
        
        taskTitleLabel.text = tracker.name
        emojiLabel.text = tracker.emoji
        
        daysLabel.text = String.localizedStringWithFormat(NSLocalizedString("numberOfDays", comment: ""), completedDays)
        
        let image = isCompletedToday ?
        doneImage?.withTintColor(cardView.backgroundColor ?? .ypWhiteDay) :
        plusImage.withTintColor(cardView.backgroundColor ?? .ypWhiteDay)
        addButton.setImage(image, for: UIControl.State.normal)
        
        self.pinnedTracker.isHidden = tracker.pinned ? false : true
        
        if isCompletedToday {
            addButton.alpha = 0.4
        } else {
            addButton.alpha = 1
        }
    }
    
    private lazy var plusImage: UIImage = {
        let pointSize = UIImage.SymbolConfiguration(pointSize: 11)
        let image = UIImage(
            systemName: "plus",
            withConfiguration: pointSize
        )?.withRenderingMode(.alwaysTemplate) ?? UIImage ()
        return image
    }()
    
    private lazy var doneImage = UIImage(named: "Done")?.withRenderingMode(.alwaysTemplate)
    
    private lazy var pinnedTracker: UIImageView = {
        let pinnedTracker = UIImageView()
        pinnedTracker.image = UIImage(named: "Pin")
        pinnedTracker.translatesAutoresizingMaskIntoConstraints = false
        return pinnedTracker
    }()
    
    private func addElements() {
        contentView.addSubview(daysLabel)
        contentView.addSubview(cardView)
        contentView.addSubview(stackView)
        contentView.addSubview(pinnedTracker)
        
        contentView.addSubview(emojiLabel)
        contentView.addSubview(taskTitleLabel)
        
        stackView.addArrangedSubview(daysLabel)
        stackView.addArrangedSubview(addButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor
            ),
            cardView.topAnchor.constraint(
                equalTo: contentView.topAnchor
            ),
            cardView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor
            ),
            cardView.heightAnchor.constraint(
                equalToConstant: 90
            ),
            emojiLabel.leadingAnchor.constraint(
                equalTo: cardView.leadingAnchor,
                constant: 12
            ),
            
            emojiLabel.topAnchor.constraint(
                equalTo: cardView.topAnchor,
                constant: 12
            ),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            
            taskTitleLabel.leadingAnchor.constraint(
                equalTo: emojiLabel.leadingAnchor
            ),
            
            taskTitleLabel.bottomAnchor.constraint(
                equalTo: cardView.bottomAnchor,
                constant: -12
            ),
            taskTitleLabel.trailingAnchor.constraint(
                equalTo: cardView.trailingAnchor,
                constant: -12
            ),
            addButton.widthAnchor.constraint(equalToConstant: 34),
            addButton.heightAnchor.constraint(equalToConstant: 34),
            
            stackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 12
            ),
            
            stackView.topAnchor.constraint(
                equalTo: cardView.bottomAnchor,
                constant: 8
            ),
            stackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -12
            ),
            pinnedTracker.centerYAnchor.constraint(equalTo: emojiLabel.centerYAnchor),
            pinnedTracker.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12)
        ])
    }
    
    @objc private func didAddButtonTapped() {
        analytics.report("click", params: ["screen": "Main", "item": "track"])
        guard let trackerId = trackerId,
              let indexPath = indexPath else {
            assertionFailure("no trackerId")
            return
        }
        
        if isCompletedToday {
            delegate?.incompleteTracker(id: trackerId, at: indexPath)
        } else {
            delegate?.completeTracker(id: trackerId, at: indexPath)
        }
    }
    
    func update(with pinned: UIImage) {
        pinnedTracker.image = pinned
    }
}
