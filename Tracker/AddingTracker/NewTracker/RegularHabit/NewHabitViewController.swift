//
//  NewHabitViewController.swift
//  Tracker
//
//  Created by Андрей Мерзликин on 03.03.2024.
//

import UIKit

protocol TrackersActions {
    func appendTracker(tracker: Tracker, category: String?)
    func updateTracker(tracker: Tracker, oldTracker: Tracker?, category: String?)
    func reload()
    func showFirstPlaceholderScreen()
}

final class NewHabitViewController: UIViewController {
    private var backingIsScheduleSet: Bool = false
    private var backingIsEmojiSelected: Bool = false
    private var backingIsColorSelected: Bool = false
    
    var trackersViewController: TrackersActions?
    let cellReuseIdentifier = "NewHabitTableViewController"
    
    private var updatedTracker: Tracker?
    private var selectedCategory: TrackerCategory?
    private var selectedColor: UIColor?
    private var selectedColorIndex: Int?
    private var selectedEmoji: String?
    
    private var selectedDays: [TrackerSchedule.DaysOfTheWeek] = []
    private(set) var viewModel: CategoryViewModel = CategoryViewModel.shared
    private var edit: Bool?
    
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
        return !(addTrackerName.text?.isEmpty ?? true)
    }
    
    private var isCategorySelected: Bool {
        //TODO: add the logic to check if a category is selected
        return true // Replace this with your actual check
    }
    
    private var isScheduleSet: Bool {
        return !selectedDays.isEmpty
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
    
    private let habitPageHeader: UILabel = {
        let header = UILabel()
        header.translatesAutoresizingMaskIntoConstraints = false
        header.text = "Новая привычка"
        header.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        header.textColor = .ypBlackDay
        return header
    }()
    
    private let dayCount: UILabel = {
        let dayCount = UILabel()
        dayCount.translatesAutoresizingMaskIntoConstraints = false
        dayCount.text = "0 дней"
        dayCount.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        dayCount.textColor = .ypBlackDay
        return dayCount
        
    }()
    
    private lazy var addTrackerName: UITextField = {
        let addTrackerName = UITextField()
        addTrackerName.translatesAutoresizingMaskIntoConstraints = false
        addTrackerName.placeholder = "Введите название трекера"
        addTrackerName.backgroundColor = .ypBackgroundDay
        addTrackerName.layer.cornerRadius = 16
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        addTrackerName.leftView = leftView
        addTrackerName.leftViewMode = .always
        addTrackerName.keyboardType = .default
        addTrackerName.returnKeyType = .done
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
    
    private let trackersTableView: UITableView = {
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
        addTrackerName.rightView = paddingView
        addTrackerName.rightViewMode = .whileEditing
        return clearButton
    }()
    
    private lazy var createButton: UIButton = {
        let createButton: UIButton = UIButton(type: .custom)
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
        collectionView.register(HabitEmojiCell.self, forCellWithReuseIdentifier: "HabitEmojiCell")
        collectionView.register(HabitEmojiHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HabitEmojiHeader.id)
        collectionView.allowsMultipleSelection = false
        return collectionView
    }()
    
    private let colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(HabitColorCell.self, forCellWithReuseIdentifier: "HabitColorCell")
        collectionView.register(HabitColorHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HabitColorHeader.id)
        collectionView.allowsMultipleSelection = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhiteDay
        addSubviews()
        setupConstraints()
        
        addTrackerName.delegate = self
        
        updateCreateButtonState()
        
        setupTrackersTableView()
        setupEmojiCollectionView()
        setupColorCollectionView()
        
    }
    
    private func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(habitPageHeader)
        scrollView.addSubview(addTrackerName)
        scrollView.addSubview(trackersTableView)
        scrollView.addSubview(emojiCollectionView)
        scrollView.addSubview(colorCollectionView)
        scrollView.addSubview(cancelButton)
        scrollView.addSubview(createButton)
    }
    
    init(edit: Bool) {
        super.init(nibName: nil, bundle: nil)
        self.edit = edit
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            habitPageHeader.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 26),
            habitPageHeader.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            habitPageHeader.heightAnchor.constraint(equalToConstant: 22),
            
            addTrackerName.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            addTrackerName.heightAnchor.constraint(equalToConstant: 75),
            addTrackerName.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            addTrackerName.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            
            trackersTableView.topAnchor.constraint(equalTo: addTrackerName.bottomAnchor, constant: 24),
            trackersTableView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            trackersTableView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            trackersTableView.heightAnchor.constraint(equalToConstant: 149),
            
            emojiCollectionView.topAnchor.constraint(equalTo: trackersTableView.bottomAnchor, constant: 32),
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
        
        if edit ?? false {
            scrollView.addSubview(dayCount)
            NSLayoutConstraint.activate([
                dayCount.topAnchor.constraint(equalTo: habitPageHeader.bottomAnchor, constant: 38),
                dayCount.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
                addTrackerName.topAnchor.constraint(equalTo: dayCount.bottomAnchor, constant: 40),
            ])
        } else {
            NSLayoutConstraint.activate([
                addTrackerName.topAnchor.constraint(equalTo: habitPageHeader.bottomAnchor, constant: 38),
            ])
        }
    }
    
    private func setupTrackersTableView() {
        trackersTableView.delegate = self
        trackersTableView.dataSource = self
        trackersTableView.register(NewHabitTrackerViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        trackersTableView.layer.cornerRadius = 16
        trackersTableView.separatorStyle = .none
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
    
    private func updateCreateButtonState() {
        let isEnabledButton = isNameEntered && isCategorySelected  && isEmojiSelected && isColorSelected
        createButton.isEnabled = isEnabledButton
        let backgroundColor: UIColor = isEnabledButton ? .ypBlackDay : .ypGray
        createButton.backgroundColor = backgroundColor
    }
    
    @objc private func clearTextField() {
        addTrackerName.text = ""
        clearButton.isHidden = true
        updateCreateButtonState()
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func createButtonTapped() {
        guard isNameEntered, isScheduleSet, isEmojiSelected, isColorSelected else {
            //TODO: Show an alert or handle the case where not all conditions are met
            return
        }
        guard let text = addTrackerName.text, !text.isEmpty,
              let color = selectedColor,
              let emoji = selectedEmoji,
              let colorIndex = selectedColorIndex
        else {
            return
        }
        
        let newTracker = Tracker(id: UUID(), name: text, color: color, emoji: emoji, schedule: self.selectedDays, pinned: false, colorIndex: colorIndex, isCompleted: false )
        if habitPageHeader.text == "Редактирование привычки" {
            trackersViewController?.updateTracker(tracker: newTracker, oldTracker: updatedTracker, category: self.selectedCategory?.title)
        } else {
            
            trackersViewController?.appendTracker(tracker: newTracker, category: self.selectedCategory?.title)
            viewModel.addTrackerToCategory(to: self.selectedCategory, tracker: newTracker)
        }
        trackersViewController?.reload()
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    func editTracker(tracker: Tracker, category: TrackerCategory?, completed: Int) {
        habitPageHeader.text = "Редактирование привычки"
        createButton.setTitle("Сохранить", for: .normal)
        updatedTracker = tracker
        addTrackerName.text = tracker.name
        selectedCategory = category
        selectedDays = tracker.schedule ?? []
        selectedColor = tracker.color
        selectedEmoji = tracker.emoji
        selectedColorIndex = tracker.colorIndex
        dayCount.text = String.localizedStringWithFormat(NSLocalizedString("numberOfDays", comment: ""), completed)
    }
}

// MARK: - SelectedDays
extension NewHabitViewController: SelectedDays {
    func save(indicies: [Int], emoji: String?, color: UIColor?) {
        self.selectedDays = indicies.map { TrackerSchedule.DaysOfTheWeek.allCases[$0] }
        self.selectedEmoji = emoji
        self.selectedColor = color
        
        self.trackersTableView.reloadData()
        
        // Update the state variables
        backingIsScheduleSet = !selectedDays.isEmpty
        backingIsEmojiSelected = selectedEmoji != nil
        backingIsColorSelected = selectedColor != nil
        
        // Update the button state
        updateCreateButtonState()
    }
}

// MARK: - UITableViewDelegate
extension NewHabitViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let addCategoryViewController = CategoryViewController()
            addCategoryViewController.viewModel.$selectedCategory.bind { [weak self] category in
                self?.selectedCategory = category
                self?.trackersTableView.reloadData()
            }
            present(addCategoryViewController, animated: true, completion: nil)
        } else if indexPath.row == 1 {
            let scheduleViewController = ScheduleViewController()
            scheduleViewController.newHabitViewController = self
            present(scheduleViewController, animated: true, completion: nil)
            selectedDays = []
        }
        trackersTableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let separatorInset: CGFloat = 16
        let separatorWidth = tableView.bounds.width - separatorInset * 2
        let separatorHeight: CGFloat = 1.0
        let separatorX = separatorInset
        let separatorY = cell.frame.height - separatorHeight
        
        let isLastCell = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        if !isLastCell {
            
            let separatorView = UIView(frame: CGRect(x: separatorX, y: separatorY, width: separatorWidth, height: separatorHeight))
            separatorView.backgroundColor = .ypGray
            cell.addSubview(separatorView)
        }
    }
}

// MARK: - UITableViewDataSource
extension NewHabitViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as? NewHabitTrackerViewCell else { return UITableViewCell() }
        if indexPath.row == 0 {
            var title = "Категория"
            if let selectedCategory = selectedCategory?.title {
                title += "\n" + selectedCategory
            }
            cell.update(with: title)
        } else if indexPath.row == 1 {
            
            var subtitle = ""
            
            if !selectedDays.isEmpty {
                if selectedDays.count == 7 {
                    subtitle = "Каждый день"
                } else {
                    subtitle = selectedDays.map { $0.shortName }.joined(separator: ", ")
                }
            }
            
            if !subtitle.isEmpty {
                cell.update(with: "Расписание\n" + subtitle)
            } else {
                cell.update(with: "Расписание")
            }
        }
        
        return cell
    }
}

// MARK: - UITextFieldDelegate
extension NewHabitViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        updateCreateButtonState()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UICollectionViewDataSource
extension NewHabitViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 18
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HabitEmojiCell", for: indexPath) as? HabitEmojiCell else {
                return UICollectionViewCell()
            }
            let emojiIndex = indexPath.item % emoji.count
            let selectedEmoji = emoji[emojiIndex]
            
            cell.emojiLabel.text = selectedEmoji
            cell.layer.cornerRadius = 16
            
            if let passedEmoji = self.selectedEmoji {
                if passedEmoji == selectedEmoji {
                    cell.backgroundColor = .ypLightGray
                }
            }
            
            return cell
        } else if collectionView == colorCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HabitColorCell", for: indexPath) as? HabitColorCell else {
                return UICollectionViewCell()
            }
            
            let colorIndex = indexPath.item % colors.count
            let selectedColor = colors[colorIndex]
            
            cell.colorView.backgroundColor = selectedColor
            cell.layer.cornerRadius = 8
            
            if let passedColorIndex = self.selectedColorIndex {
                if passedColorIndex == colorIndex {
                    cell.layer.borderWidth = 3
                    cell.layer.borderColor = cell.colorView.backgroundColor?.withAlphaComponent(0.3).cgColor
                }
            }
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView:UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if collectionView == emojiCollectionView {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HabitEmojiHeader.id, for: indexPath) as? HabitEmojiHeader else {
                return UICollectionReusableView()
            }
            header.headerText = "Emoji"
            return header
        } else if collectionView == colorCollectionView {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HabitColorHeader.id, for: indexPath) as? HabitColorHeader else {
                return UICollectionReusableView()
            }
            header.headerText = "Цвет"
            return header
        }
        
        return UICollectionReusableView()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension NewHabitViewController: UICollectionViewDelegateFlowLayout {
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
extension NewHabitViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            collectionView.visibleCells.forEach {
                $0.backgroundColor = .ypWhiteDay
            }
            let cell = collectionView.cellForItem(at: indexPath) as? HabitEmojiCell
            cell?.backgroundColor = .ypLightGray
            
            selectedEmoji = cell?.emojiLabel.text
        } else if collectionView == colorCollectionView {
            collectionView.visibleCells.forEach {
                $0.layer.borderWidth = 0
            }
            let cell = collectionView.cellForItem(at: indexPath) as? HabitColorCell
            cell?.layer.borderWidth = 3
            cell?.layer.borderColor = cell?.colorView.backgroundColor?.withAlphaComponent(0.3).cgColor
            
            selectedColor = cell?.colorView.backgroundColor
            selectedColorIndex = indexPath.row
            updateCreateButtonState()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            let cell = collectionView.cellForItem(at: indexPath) as? HabitEmojiCell
            cell?.backgroundColor = .ypWhiteDay
        } else if collectionView == colorCollectionView {
            let cell = collectionView.cellForItem(at: indexPath) as? HabitColorCell
            cell?.layer.borderWidth = 0
            selectedColor = nil
            updateCreateButtonState()
        }
    }
}
