//
//  IrregularEventViewController.swift
//  Tracker
//
//  Created by Андрей Мерзликин on 03.03.2024.
//

import UIKit

final class IrregularEventViewController: UIViewController {
    private var backingIsEmojiSelected: Bool = false
    private var backingIsColorSelected: Bool = false
    
    let irregularEventCellReuseIdentifier = "IrregularEventTableViewCell"
    var trackersViewController: TrackersActions?
    
    private let addCategoryViewController = CategoryViewController()
    
    private var selectedCategory: TrackerCategory?
    private var selectedColor: UIColor?
    private var selectedColorIndex: Int?
    private var selectedEmoji: String?
    
    private let colors: [UIColor] = [
        .ypColorSelection1, .ypColorSelection2, .ypColorSelection3,
        .ypColorSelection4, .ypColorSelection5, .ypColorSelection6,
        .ypColorSelection7, .ypColorSelection8, .ypColorSelection9,
        .ypColorSelection10, .ypColorSelection11, .ypColorSelection12,
        .ypColorSelection13, .ypColorSelection14, .ypColorSelection15,
        .ypColorSelection16, .ypColorSelection17, .ypColorSelection18
    ]
    
    private let emoji: [String] = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶",
        "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
    ]
    
    private var isNameEntered: Bool {
        return !(addEventName.text?.isEmpty ?? true)
    }
    
    private var isCategorySelected: Bool {
        //TODO: add the logic to check if a category is selected
        return selectedCategory != nil
    }
    
    
    private var isEmojiSelected: Bool {
        return selectedEmoji != nil
    }
    
    private var isColorSelected: Bool {
        return selectedColor != nil
    }
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = true
        return scrollView
    }()
    
    private let eventPageHeader: UILabel = {
        let header = UILabel()
        header.translatesAutoresizingMaskIntoConstraints = false
        header.text = "Новое нерегулярное событие"
        header.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        header.textColor = .ypBlackDay
        return header
    }()
    
    private lazy var addEventName: UITextField = {
        let addTrackerName = UITextField()
        addTrackerName.translatesAutoresizingMaskIntoConstraints = false
        addTrackerName.placeholder = "Введите название трекера"
        addTrackerName.backgroundColor = .ypBackgroundDay
        addTrackerName.layer.cornerRadius = 16
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        addTrackerName.leftView = leftView
        addTrackerName.leftViewMode = .always
        addTrackerName.returnKeyType = .done
        addTrackerName.keyboardType = .default
        addTrackerName.becomeFirstResponder()
        return addTrackerName
    }()
    
    private lazy var cancelButton: UIButton = {
        let cancelButton = UIButton(type: .custom)
        cancelButton.setTitleColor(.ypRed, for: .normal)
        cancelButton.layer.borderWidth = 1.0
        cancelButton.layer.borderColor = UIColor.ypRed.cgColor
        cancelButton.layer.cornerRadius = 16
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        return cancelButton
    }()
    
    private let irregularEventTableView: UITableView = {
        let trackersTableView = UITableView()
        trackersTableView.translatesAutoresizingMaskIntoConstraints = false
        return trackersTableView
    }()
    
    private lazy var clearButton: UIButton = {
        let clearButton = UIButton(type: .custom)
        clearButton.setImage(UIImage(named: "Clean_icon"), for: .normal)
        clearButton.frame = CGRect(x: 0, y: 0, width: 17, height: 17)
        clearButton.contentMode = .scaleAspectFit
        clearButton.addTarget(self, action: #selector(clearTextField), for: .touchUpInside)
        clearButton.isHidden = true
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 29, height: 17))
        paddingView.addSubview(clearButton)
        addEventName.rightView = paddingView
        addEventName.rightViewMode = .whileEditing
        return clearButton
    }()
    
    private lazy var createButton: UIButton = {
        let createButton = UIButton(type: .custom)
        createButton.setTitleColor(.ypWhiteDay, for: .normal)
        createButton.backgroundColor = .ypGray
        createButton.layer.cornerRadius = 16
        createButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        createButton.setTitle("Создать", for: .normal)
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.isEnabled = false
        return createButton
    }()
    
    private let emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(EventEmojiCell.self, forCellWithReuseIdentifier: "Event emoji cell")
        collectionView.register(EventEmojiHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: EventEmojiHeader.id)
        collectionView.allowsMultipleSelection = false
        return collectionView
    }()
    
    private let colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(EventColorCell.self, forCellWithReuseIdentifier: "Event color cell")
        collectionView.register(EventColorHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: EventColorHeader.id)
        collectionView.allowsMultipleSelection = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhiteDay
        addSubviews()
        setupConstraints()
        
        addEventName.delegate = self
        
        updateCreateButtonState()
        
        setupIrregularEventTableView()
        setupEmojiCollectionView()
        setupColorCollectionView()
    }
    
    private func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(eventPageHeader)
        scrollView.addSubview(addEventName)
        scrollView.addSubview(irregularEventTableView)
        scrollView.addSubview(emojiCollectionView)
        scrollView.addSubview(colorCollectionView)
        scrollView.addSubview(cancelButton)
        scrollView.addSubview(createButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            eventPageHeader.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 26),
            eventPageHeader.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            eventPageHeader.heightAnchor.constraint(equalToConstant: 22),
            
            addEventName.topAnchor.constraint(equalTo: eventPageHeader.bottomAnchor, constant: 38),
            addEventName.centerXAnchor.constraint(equalTo: eventPageHeader.centerXAnchor),
            addEventName.heightAnchor.constraint(equalToConstant: 75),
            addEventName.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            addEventName.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            
            irregularEventTableView.topAnchor.constraint(equalTo: addEventName.bottomAnchor, constant: 24),
            irregularEventTableView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            irregularEventTableView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            irregularEventTableView.heightAnchor.constraint(equalToConstant: 75),//149
            
            emojiCollectionView.topAnchor.constraint(equalTo: irregularEventTableView.bottomAnchor, constant: 32),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 222),
            emojiCollectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 18),
            emojiCollectionView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -18),
            
            colorCollectionView.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 222),
            colorCollectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 18),
            colorCollectionView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -18),
            
            cancelButton.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 16),
            cancelButton.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0),
            cancelButton.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: colorCollectionView.centerXAnchor, constant: -4),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            createButton.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0),
            createButton.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.leadingAnchor.constraint(equalTo: colorCollectionView.centerXAnchor, constant: 4)
        ])
    }
    
    private func updateCreateButtonState() {
        createButton.isEnabled = isNameEntered && isCategorySelected  && isEmojiSelected && isColorSelected
        
        if createButton.isEnabled {
            createButton.backgroundColor = .ypBlackDay
        } else {
            createButton.backgroundColor = .ypGray
        }
    }
    
    private func setupIrregularEventTableView() {
        irregularEventTableView.delegate = self
        irregularEventTableView.dataSource = self
        irregularEventTableView.register(IrregularEventCell.self, forCellReuseIdentifier: irregularEventCellReuseIdentifier)
        irregularEventTableView.layer.cornerRadius = 16
        irregularEventTableView.separatorStyle = .none
    }
    
    private func setupEmojiCollectionView() {
        emojiCollectionView.dataSource = self
        emojiCollectionView.delegate = self
        emojiCollectionView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupColorCollectionView() {
        colorCollectionView.dataSource = self
        colorCollectionView.delegate = self
        colorCollectionView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @objc private func clearTextField() {
        addEventName.text = ""
        clearButton.isHidden = true
        updateCreateButtonState()
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func createButtonTapped() {
        guard isNameEntered, isEmojiSelected, isColorSelected else {
                    //TODO: Show an alert or handle the case where not all conditions are met
                    return
                }
        guard let text = addEventName.text, !text.isEmpty,
              let color = selectedColor,
              let emoji = selectedEmoji,
              let colorIndex = selectedColorIndex
        else {
            return
        }
        let newEvent = Tracker(id: UUID(), name: text, color: color, emoji: emoji, schedule: TrackerSchedule.DaysOfTheWeek.allCases, pinned: false, colorIndex: colorIndex, isCompleted: false)
        trackersViewController?.appendTracker(tracker: newEvent, category: self.selectedCategory?.title)
        addCategoryViewController.viewModel.addTrackerToCategory(to: self.selectedCategory, tracker: newEvent)
        trackersViewController?.reload()
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate
extension IrregularEventViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let addCategoryViewController = CategoryViewController()
        addCategoryViewController.viewModel.$selectedCategory.bind { [weak self] category in
            self?.selectedCategory = category
            self?.irregularEventTableView.reloadData()
        }
        irregularEventTableView.deselectRow(at: indexPath, animated: true)
        present(addCategoryViewController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource
extension IrregularEventViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: irregularEventCellReuseIdentifier, for: indexPath) as? IrregularEventCell
        
        var title = "Категория"
        if let selectedCategory = selectedCategory?.title {
            title += "\n" + selectedCategory
        }
        cell?.update(with: title)
        return cell ?? IrregularEventCell()
    }
}

// MARK: - UITextFieldDelegate
extension IrregularEventViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        updateCreateButtonState()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UICollectionViewDataSource
extension IrregularEventViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 18
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Event emoji cell", for: indexPath) as? EventEmojiCell else {
                return UICollectionViewCell()
            }
            let emojiIndex = indexPath.item % emoji.count
            let selectedEmoji = emoji[emojiIndex]
            
            cell.emojiLabel.text = selectedEmoji
            cell.layer.cornerRadius = 16
            
            return cell
        } else if collectionView == colorCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Event color cell", for: indexPath) as? EventColorCell else {
                return UICollectionViewCell()
            }
            
            let colorIndex = indexPath.item % colors.count
            let selectedColor = colors[colorIndex]
            
            cell.colorView.backgroundColor = selectedColor
            cell.layer.cornerRadius = 8
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView:UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if collectionView == emojiCollectionView {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: EventEmojiHeader.id, for: indexPath) as? EventEmojiHeader else {
                return UICollectionReusableView()
            }
            header.headerText = "Emoji"
            return header
        } else if collectionView == colorCollectionView {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: EventColorHeader.id, for: indexPath) as? EventColorHeader else {
                return UICollectionReusableView()
            }
            header.headerText = "Цвет"
            return header
        }
        
        return UICollectionReusableView()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension IrregularEventViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width - 36
        let cellWidth = collectionViewWidth / 6
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
    }
    
}

// MARK: - UICollectionViewDelegate
extension IrregularEventViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            let cell = collectionView.cellForItem(at: indexPath) as? EventEmojiCell
            cell?.backgroundColor = .ypLightGray
            
            selectedEmoji = cell?.emojiLabel.text
        } else if collectionView == colorCollectionView {
            let cell = collectionView.cellForItem(at: indexPath) as? EventColorCell
            cell?.layer.borderWidth = 3
            cell?.layer.borderColor = cell?.colorView.backgroundColor?.withAlphaComponent(0.3).cgColor
            
            selectedColor = cell?.colorView.backgroundColor
            selectedColorIndex = indexPath.row
            updateCreateButtonState()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            let cell = collectionView.cellForItem(at: indexPath) as? EventEmojiCell
            cell?.backgroundColor = .ypWhiteDay
        } else if collectionView == colorCollectionView {
            let cell = collectionView.cellForItem(at: indexPath) as? EventColorCell
            cell?.layer.borderWidth = 0
            selectedColor = nil
            updateCreateButtonState()
        }
    }
}
