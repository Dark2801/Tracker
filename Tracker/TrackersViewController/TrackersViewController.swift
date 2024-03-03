//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Андрей Мерзликин on 03.03.2024.
//

import UIKit
import Foundation

final class TrackersViewController: UIViewController, UITextFieldDelegate {
    private var trackerStore = TrackerStore()
    private var trackerRecordStore = TrackerRecordStore()
    
    private(set) var categoryViewModel: CategoryViewModel = CategoryViewModel.shared
    private let analytics = AnalyticsService.shared
    
    private var trackers: [Tracker] = []
    private var pinnedTrackers: [Tracker] = []
    private var categories: [TrackerCategory] = []
    private var filteredCategories: [TrackerCategory] = []
    private (set) var completedTrackers: [TrackerRecord] = []
    
    private var selectedDate: Int?
    private var filterText: String?
    private var currentFilter: Filters? = .allTrackers
    
    private let collectionView = UICollectionView(
        frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()
    )
    
    private let params = TrackerGeometricParams(
        cellCount: 2,
        topDistance: 9,
        leftInset: 16,
        rightInset: 16,
        cellSpacing: 9
    )
    
    private let titleHeader: UILabel = {
        let label = UILabel ()
        label.text = NSLocalizedString("app.title", comment: "")
        label.textColor = .ypBlackDay
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var searchTextField: UISearchTextField = {
        let searchField = UISearchTextField()
        searchField.backgroundColor = .ypBackground
        searchField.textColor = .ypBlackDay
        searchField.font = .systemFont(ofSize: 17, weight: .medium)
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.layer.cornerRadius = 10
        searchField.placeholder = NSLocalizedString("search", comment: "Search")
        return searchField
    }()
    
    private lazy var datePickerButton: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.addTarget(self, action: #selector(didChangeDate), for: .valueChanged)
        datePicker.datePickerMode = .date
        datePicker.tintColor = .blue
        
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.calendar.firstWeekday = 2
        datePicker.clipsToBounds = true
        datePicker.layer.cornerRadius = 8
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            datePicker.widthAnchor.constraint(equalToConstant: 100)
        ])
        return datePicker
    }()
    
    private lazy var blankPageImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "Blank_page_image_placeholder")
        return imageView
    }()
    
    private lazy var blankPageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("whatWillWeTrack", comment: "What will we track?")
        label.textAlignment = .center
        label.textColor = .ypBlackDay
        return label
    }()
    
    private let trackersNotFoundImage: UIImageView = {
        let imageView = UIImageView()
        imageView .translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "Not_found_image_placeholder")
        return imageView
    }()
    
    private let trackerNotFoundText: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("nothingFound", comment: "No results found")
        label.textColor = .ypBlackDay
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private lazy var plusButton: UIButton = {
        let addTrackerButton = UIButton(type: .system)
        addTrackerButton.setImage(UIImage(named: "Plus"), for: .normal)
        addTrackerButton.tintColor = .ypBlackDay
        addTrackerButton.translatesAutoresizingMaskIntoConstraints = false
        addTrackerButton.addTarget(self, action: #selector (didAddTrackerButtonTapped), for: .touchUpInside)
        return addTrackerButton
    }()
    
    private lazy var filtersButton: UIButton = {
        let filtersButton = UIButton()
        filtersButton.layer.cornerRadius = 16
        filtersButton.backgroundColor = .ypBlue
        filtersButton.setTitle(NSLocalizedString("filter.title", comment: ""), for: .normal)
        filtersButton.translatesAutoresizingMaskIntoConstraints = false
        filtersButton.addTarget(self, action: #selector(filtersButtonTapped), for: .touchUpInside)
        return filtersButton
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categories = categoryViewModel.categories
        categories.insert(TrackerCategory(title: "Закрепленные", trackers: pinnedTrackers), at: 0)
        trackerStore.delegate = self
        trackerRecordStore.delegate = self
        trackers = trackerStore.trackers.filter{ !$0.pinned }
        pinnedTrackers = trackerStore.trackers.filter{ $0.pinned }
        completedTrackers = trackerRecordStore.trackerRecords
        
        reloadFilteredCategories(text: searchTextField.text, date: datePickerButton.date)
        showFirstPlaceholderScreen()
        configureView()
        setupNav()
        addElements()
        configureCollectionView()
        setupConstraints()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analytics.report("open", params: ["screen": "Main"])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        analytics.report("close", params: ["screen": "Main"])
    }
    
    
    private func configureView() {
        view.backgroundColor = .ypWhiteDay
        searchTextField.returnKeyType = .done
    }
    
    private func setupNav() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: plusButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePickerButton)
    }
    
    private func addElements() {
        view.addSubview(titleHeader)
        view.addSubview(plusButton)
        view.addSubview(searchTextField)
        view.addSubview(datePickerButton)
        
        view.addSubview(blankPageImage)
        view.addSubview(blankPageLabel)
        view.addSubview(trackersNotFoundImage)
        view.addSubview(trackerNotFoundText)
        view.addSubview(collectionView)
        view.addSubview(filtersButton)
    }
    
    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.allowsMultipleSelection = false
        
        collectionView.register(
            TrackerCell.self,
            forCellWithReuseIdentifier: "cell"
        )
        collectionView.register(
            TrackerTitleSectionView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerTitleSectionView.id
        )
        collectionView.backgroundColor = .ypWhiteDay
        searchTextField.delegate = self
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleHeader.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleHeader.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            searchTextField.topAnchor.constraint(equalTo: titleHeader.bottomAnchor, constant: 7),
            searchTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            searchTextField.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
            blankPageImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            blankPageImage.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 220),
            blankPageImage.heightAnchor.constraint(equalToConstant: 80),
            blankPageImage.widthAnchor.constraint(equalToConstant: 80),
            blankPageLabel.centerXAnchor.constraint(equalTo: blankPageImage.centerXAnchor),
            blankPageLabel.topAnchor.constraint(equalTo: blankPageImage.bottomAnchor, constant: 8),
            trackersNotFoundImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            trackersNotFoundImage.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 220),
            trackersNotFoundImage.heightAnchor.constraint(equalToConstant: 80),
            trackersNotFoundImage.widthAnchor.constraint(equalToConstant: 80),
            trackerNotFoundText.centerXAnchor.constraint(equalTo: trackersNotFoundImage.centerXAnchor),
            trackerNotFoundText.topAnchor.constraint(equalTo: trackersNotFoundImage.bottomAnchor, constant: 8),
            collectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 24),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            filtersButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 130),
            filtersButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -130),
            filtersButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            filtersButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func didAddTrackerButtonTapped() {
        analytics.report("click", params: ["screen": "Main", "item": "add_track"])
        let createNewTrackerVC = NewTrackerViewController()
        createNewTrackerVC.trackersViewController = self
        present(createNewTrackerVC, animated: true, completion: nil)
    }
    
    @objc private func didChangeDate() {
        if currentFilter == .todayTrackers,
           !Calendar.current.isDate(datePickerButton.date, inSameDayAs: Date()) {
            currentFilter = .allTrackers
            filtersButton.setTitleColor(.white, for: .normal)
        }
        reloadFilteredCategories(text: searchTextField.text, date: datePickerButton.date)
        showSecondPlaceholderScreen()
        collectionView.reloadData()
    }
    
    @objc private func filtersButtonTapped() {
        analytics.report("click", params: ["screen": "Main", "item": "filter"])
        
        let filtersViewController = FiltersViewController()
        filtersViewController.delegate = self
        filtersViewController.selectedFilters = currentFilter
        present(filtersViewController, animated: true)
    }
    
    private func applyFilter(_ filter: Filters) {
        currentFilter = filter
        
        switch filter {
        case .completedTrackers:
            filteredCategories = filterCategoriesByCompletionStatus(completed: true)
        case .unCompletedTrackers:
            filteredCategories = filterCategoriesByCompletionStatus(completed: false)
        case .todayTrackers:
            filterCategoriesForToday()
        case .allTrackers:
            reloadFilteredCategories(text: searchTextField.text, date: datePickerButton.date)
        }
        
        collectionView.reloadData()
    }
    
    private func filterCategoriesByCompletionStatus(completed: Bool) -> [TrackerCategory] {
        return categories.map { category in
            TrackerCategory(
                title: category.title,
                trackers: category.trackers.filter { (tracker: Tracker) -> Bool in
                    return tracker.isCompleted == completed
                }
            )
        }
        .filter { category in
            !category.trackers.isEmpty
        }
    }
    
    private func filterCategoriesForToday() {
        let todayCategories = categories.map { category in
            TrackerCategory(
                title: category.title,
                trackers: category.trackers.filter { tracker in
                    let dateCondition = tracker.schedule?.contains { day in
                        guard let currentDay = self.selectedDate else {
                            return true
                        }
                        return day.rawValue == currentDay
                    } ?? false
                    
                    return dateCondition
                }
            )
        }
            .filter { category in
                !category.trackers.isEmpty
            }
        
        filteredCategories = todayCategories
    }
    
    private func reloadFilteredCategories(text: String?, date: Date) {
        let calendar = Calendar.current
        let filterWeekday = calendar.component(.weekday, from: date)
        self.selectedDate = filterWeekday
        
        filteredCategories = categories.map { category in
            if category.title == "Закрепленные" {
                return TrackerCategory(title: category.title, trackers: pinnedTrackers.filter { tracker in
                    return tracker.name.contains(self.filterText ?? "") || (self.filterText ?? "").isEmpty
                })
            } else {
                return TrackerCategory(title: category.title, trackers: trackers.filter { tracker in
                    let categoriesContains = category.trackers.contains { $0.id == tracker.id }
                    let pinnedContains = pinnedTrackers.contains{ $0.id == tracker.id }
                    
                    let dateCondition = tracker.schedule?.contains { day in
                        guard let currentDay = self.selectedDate else {
                            return true
                        }
                        return day.rawValue == currentDay
                    } ?? false
                    let textCondition = tracker.name.contains(self.filterText ?? "") || (self.filterText ?? "").isEmpty
                    return textCondition && dateCondition && categoriesContains && !pinnedContains
                })
            }
        }
        .filter { category in
            !category.trackers.isEmpty
        }
    }
}

extension TrackersViewController: TrackerStoreDelegate {
    func store() {
        let fromDb = trackerStore.trackers
        trackers = fromDb.filter{ !$0.pinned }
        pinnedTrackers = fromDb.filter{ $0.pinned }
        reloadFilteredCategories(text: searchTextField.text, date: datePickerButton.date)
        collectionView.reloadData()
    }
}

extension TrackersViewController: UITextViewDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.filterText = textField.text
        reloadFilteredCategories(text: searchTextField.text, date: datePickerButton.date)
        showSecondPlaceholderScreen()
    }
    
    func textFieldShouldReturn(_textField: UITextField) -> Bool {
        return true
    }
}

// MARK: - TrackersActions
extension TrackersViewController: TrackersActions {
    func reload() {
        self.collectionView.reloadData()
    }
    
    func updateTracker(tracker: Tracker, oldTracker: Tracker?, category: String?) {
        guard let category = category, let oldTracker = oldTracker else { return }
        try? self.trackerStore.updateTracker(tracker, oldTracker: oldTracker)
        let foundCategory = self.categories.first { ctgry in
            ctgry.title == category
        }
        if foundCategory != nil {
            self.categories = self.categories.map { ctgry in
                if (ctgry.title == category) {
                    var updatedTrackers = ctgry.trackers
                    updatedTrackers.append(tracker)
                    return TrackerCategory(title: ctgry.title, trackers: updatedTrackers)
                } else {
                    return TrackerCategory(title: ctgry.title, trackers: ctgry.trackers)
                }
            }
        } else {
            self.categories.append(TrackerCategory(title: category, trackers: [tracker]))
        }
        reloadFilteredCategories(text: searchTextField.text, date: datePickerButton.date)
        showSecondPlaceholderScreen()
        collectionView.reloadData()
    }
    func appendTracker(tracker: Tracker, category: String?) {
        guard let category = category else { return }
        try? self.trackerStore.addNewTracker(tracker)
        let foundCategory = self.categories.first { currentCategory in
            currentCategory.title == category
        }
        if foundCategory != nil {
            self.categories = self.categories.map { currentCategory in
                if (currentCategory.title == category) {
                    var updatedTrackers = currentCategory.trackers
                    updatedTrackers.append(tracker)
                    return TrackerCategory(title: currentCategory.title, trackers: updatedTrackers)
                } else {
                    return TrackerCategory(title: currentCategory.title, trackers: currentCategory.trackers)
                }
            }
        } else {
            self.categories.append(TrackerCategory(title: category, trackers: [tracker]))
        }
        reloadFilteredCategories(text: searchTextField.text, date: datePickerButton.date)
        showSecondPlaceholderScreen()
        collectionView.reloadData()
    }
    
    // filtered by search input
    func showFirstPlaceholderScreen() {
        if filteredCategories.isEmpty {
            collectionView.isHidden = true
            trackersNotFoundImage.isHidden = true
            trackerNotFoundText.isHidden = true
        } else {
            collectionView.isHidden = false
            trackersNotFoundImage.isHidden = false
            trackerNotFoundText.isHidden = false
        }
    }
    
    // filtered by date
    func showSecondPlaceholderScreen() {
        if filteredCategories.isEmpty {
            collectionView.isHidden = true
            blankPageImage.isHidden = true
            blankPageLabel.isHidden = true
            trackersNotFoundImage.isHidden = false
            trackerNotFoundText.isHidden = false
        } else {
            collectionView.isHidden = false
            blankPageImage.isHidden = false
            blankPageLabel.isHidden = false
            trackersNotFoundImage.isHidden = true
            trackerNotFoundText.isHidden = true
        }
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredCategories.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let trackers = filteredCategories[section].trackers
        return trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.row]
        cell.prepareForReuse()
        cell.delegate = self
        let isCompletedToday = isTrackerCompletedToday(id: tracker.id)
        let completedDays = completedTrackers.filter {
            $0.trackerId == tracker.id
        }.count
        
        cell.configure(
            with: tracker,
            isCompletedToday: isCompletedToday,
            completedDays: completedDays,
            indexPath: indexPath
        )
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind, withReuseIdentifier: TrackerTitleSectionView.id, for: indexPath) as? TrackerTitleSectionView else {
            return UICollectionReusableView()
        }
        guard indexPath.section < filteredCategories.count else {
            return view
        }
        let titleCategory = filteredCategories[indexPath.section].title
        view.headerText = titleCategory
        
        return view
    }
    
    private func isTrackerCompletedToday (id: UUID) -> Bool {
        completedTrackers.contains { trackerRecord in
            isSameTrackerRecord(trackerRecord: trackerRecord, id: id)
        }
    }
    
    private func isSameTrackerRecord(trackerRecord: TrackerRecord, id: UUID) -> Bool {
        let isSameDay = Calendar.current.isDate(trackerRecord.date,
                                                inSameDayAs: datePickerButton.date)
        return trackerRecord.trackerId == id && isSameDay
    }
}

// MARK: - TrackerCellDelegate
extension TrackersViewController: TrackerRecordStoreDelegate {
    func storeRecord() {
        completedTrackers = trackerRecordStore.trackerRecords
        collectionView.reloadData()
    }
}

extension TrackersViewController: TrackerCellDelegate {
    func completeTracker (id: UUID, at indexPath: IndexPath) {
        let currentDate = Date()
        let selectedDate = datePickerButton.date
        let calendar = Calendar.current
        if calendar.compare(selectedDate, to: currentDate, toGranularity: .day) != .orderedDescending {
            let trackerRecord = TrackerRecord(trackerId: id, date: selectedDate)
            try? self.trackerRecordStore.addNewTrackerRecord(trackerRecord)
        } else {
            return
        }
    }
    func incompleteTracker(id: UUID, at indexPath: IndexPath) {
        let toRemove = completedTrackers.first {
            isSameTrackerRecord(trackerRecord: $0, id: id)
        }
        
        try? self.trackerRecordStore.removeTrackerRecord(toRemove)
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - params.paddingWidth
        let cellWidth = availableWidth / CGFloat(params.cellCount)
        return CGSize(width: cellWidth, height: 132)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        params.cellSpacing
    }
    
    func collectionView(_collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 12, left: params.leftInset, bottom: 0, right:
                        params.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        params.leftInset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let size = CGSize(width: collectionView.frame.width, height: 47)
        return size
    }
}

// MARK: - UICollectionViewDelegate
extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let tracker = self.filteredCategories[indexPath.section].trackers[indexPath.row]
        
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: { [weak self] () -> UIViewController? in
            guard let self = self else { return nil }
            
            let previewVC = PreviewViewController()
            let cellSize = CGSize(width: self.collectionView.bounds.width / 2 - 5, height: (self.collectionView.bounds.width / 2 - 5) * 0.55)
            previewVC.configureView(sizeForPreview: cellSize, tracker: tracker)
            
            return previewVC
        }) { [weak self] _ in
            let pinAction: UIAction
            if tracker.pinned {
                pinAction = UIAction(title: "Открепить", handler: { [weak self] _ in
                    try? self?.trackerStore.pinTracker(tracker, value: false)
                })
            } else {
                pinAction = UIAction(title: "Закрепить", handler: { [weak self] _ in
                    try? self?.trackerStore.pinTracker(tracker, value: true)
                })
            }
            
            let editAction = UIAction(title: "Редактировать", handler: { [weak self] _ in
                guard let self = self else { return }
                self.analytics.report("click", params: ["screen": "Main", "item": "edit"])
                let addHabit = NewHabitViewController(edit: true)
                addHabit.trackersViewController = self
                
                addHabit.editTracker(
                    tracker: tracker,
                    category: self.categories.first {
                        $0.trackers.contains {
                            $0.id == tracker.id
                        }
                    },
                    completed: self.completedTrackers.filter {
                        $0.trackerId == tracker.id
                    }.count
                )
                self.present(addHabit, animated: true)
                
            })
            
            let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { [weak self] _ in
                guard let self = self else { return }
                self.analytics.report("click", params: ["screen": "Main", "item": "delete"])
                
                let alertController = UIAlertController(title: nil, message: "Уверены что хотите удалить трекер?", preferredStyle: .actionSheet)
                let deleteConfirmationAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
                    try? self?.trackerStore.deleteTracker(tracker)
                    self?.showFirstPlaceholderScreen()
                }
                alertController.addAction(deleteConfirmationAction)
                
                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                
                self.present(alertController, animated: true, completion: nil)
                
            }
            
            let actions = [pinAction, editAction, deleteAction]
            return UIMenu(title: "", children: actions)
        }
        
        return configuration
    }
}

extension TrackersViewController: FiltersViewControllerDelegate {
    func filtersViewController(_ controller: FiltersViewController, didSelectFilter filter: Filters) {
        applyFilter(filter)
    }
}
