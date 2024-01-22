//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Андрей Мерзликин on 20.12.2023.
//

import UIKit

private enum SizeCollectionView: CGFloat {
    case distanceBetweenCells = 16
    case betweenHeaderAndCell = 12
}

protocol TrackerViewControllerDelegate: AnyObject {
    func createTracker(_ tracker: Tracker?, titleCategory: String?)
}

final class TrackerViewController: UIViewController {
    
    // MARK: Geometric parameters collectionView
    private let params = GeometryParams(cellCount: 2, leftInset: 16, rightInset: 16, cellSpacing: 9)
    
    private let trackerStore = TrackerStore()
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerRecordStore = TrackerRecordStore()
    
    private let refreshControl = UIRefreshControl()
        
    private var currentDate: Date { return datePicker.date }
    
    private var isCompleteSelectedTracker: [UUID: Bool] = [:]
    
    private var filterAllTrackersIsTrue = false
    
    private(set) var pinnedCategories: [TrackerCategory] = []
    
    weak var delegateStatistic: StatisticViewControllerProtocol?
        
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
        collectionView.register(HeaderViewCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.backgroundColor = ColoursTheme.blackDayWhiteDay
        collectionView.allowsMultipleSelection = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 16, left: .zero, bottom: .zero, right: .zero)
        return collectionView
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .compact
        picker.locale = .autoupdatingCurrent
        picker.datePickerMode = .date
        picker.tintColor = .yp_Blue
        picker.date = Date()
        picker.subviews[0].backgroundColor = ColoursTheme.whiteLightGray
        picker.subviews[0].layer.cornerRadius = 8
        picker.overrideUserInterfaceStyle = .light
        picker.addTarget(self, action: #selector(datePickerValueChanges), for: .valueChanged)
        return picker
    }()
    
    private lazy var filterButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .yp_Blue.withAlphaComponent(0.9)
        button.setTitle(LocalizableKeys.filterButton, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        button.setTitleColor(.ypWhiteDay, for: .normal)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(addFilter), for: .touchUpInside)
        return button
    }()
    
    private var pinTracker = false
    
    private lazy var weekDay = {
        datePicker.calendar.component(.weekday, from: currentDate)
    }()
    
    private var searchController: UISearchController?
    
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var filteredCategoriesByDate: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    
    // MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupNavigationBar()
        setupSearch()
        refreshControlSetup()
        filteredByDate(nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsService.openScreenReport(screen: .main)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AnalyticsService.closeScreenReport(screen: .main)
    }
    
    private func refreshControlSetup() {
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        collectionView.refreshControl = nil
    }
    
    private func showBackgroundView(forCollection: Bool) {
        if visibleCategories.isEmpty {
            let emptyView = EmptyView(
                frame: CGRect(
                    x: 0,
                    y: 0,
                    width: view.bounds.width,
                    height: view.bounds.height
                ),
                image: forCollection ? ImageAssets.trackerErrorImage : ImageAssets.trackerNoFoundImage,
                text: forCollection ? LocalizableKeys.emptyErrorStub : LocalizableKeys.searchErrorStub
            )
            collectionView.backgroundView = emptyView
            collectionView.isScrollEnabled = false
            filterButton.isHidden = false
        } else {
            collectionView.isScrollEnabled = true
            collectionView.backgroundView = nil
            filterButton.isHidden = false
        }
       collectionView.reloadData()

    }
    
    private func setupNavigationBar() {
        if let navBar = navigationController?.navigationBar {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationItem.title = LocalizableKeys.trackersNavigationItem
            
            let leftButton = UIBarButtonItem(image: ImageAssets.trackerAddButton, style: .plain, target: self, action: #selector(addNewTracker))
            leftButton.tintColor = ColoursTheme.whiteDayBlackDay
            navBar.topItem?.setLeftBarButton(leftButton, animated: false)
            
            let dateButton = UIBarButtonItem(customView: datePicker)
            
            navBar.topItem?.setRightBarButton(dateButton, animated: true)
        }
    }
    
    private func filteredByDate(_ text: String?) {
        let filterWeekday = Calendar.current.component(.weekday, from: datePicker.date)
        let filterText = (text ?? "").lowercased()
        visibleCategories = categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                let textCondition = filterText.isEmpty || tracker.name.lowercased().contains(filterText)
                guard let timetable = tracker.timetable, !timetable.isEmpty else {
                    return textCondition
                }
                let dateCondition = timetable.contains { weekDay in
                    weekDay == WeekDays[filterWeekday]
                }
                return textCondition && dateCondition
            }
            if trackers.isEmpty {
                return nil
            }
            return TrackerCategory(title: category.title, trackers: trackers)
        }
        (visibleCategories.isEmpty && !filterText.isEmpty) ? showBackgroundView(forCollection: false) : showBackgroundView(forCollection: true)
    }
    
    // MARK: Selectors
    @objc
    private func handleRefresh(_ sender: UIRefreshControl) {
        sender.endRefreshing()
    }
    
    @objc
    private func addNewTracker() {
        AnalyticsService.addTrackReport()
        
        let trackersTypeViewController = TrackersTypeViewController()
        trackersTypeViewController.title = LocalizableKeys.chooseTypeOfTracker
        trackersTypeViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: trackersTypeViewController)
        navigationController.navigationBar.barTintColor = ColoursTheme.whiteDayBlackDay
        navigationController.navigationBar.shadowImage = UIImage()
        present(navigationController, animated: true)
    }
    
    @objc
    private func datePickerValueChanges(_ sender: UIDatePicker) {
        filteredByDate(nil)
        dismiss(animated: true)
    }
    
    @objc
    private func addFilter() {
        AnalyticsService.addFilterReport()
        
        let filterViewController = FiltersViewController()
        filterViewController.delegate = self
        filterViewController.title = LocalizableKeys.filterButton
        let navigationController = UINavigationController(rootViewController: filterViewController)
        navigationController.navigationBar.barTintColor = ColoursTheme.whiteDayBlackDay
        navigationController.navigationBar.shadowImage = UIImage()
        present(navigationController, animated: true)
    }
}

// MARK: - TrackerViewControllerDelegate
extension TrackerViewController: TrackerViewControllerDelegate {
    func createTracker(_ tracker: Tracker?, titleCategory: String?) {
        guard let newTracker = tracker, let newTitleCategory = titleCategory else { return }
        let trackerExists = categories.flatMap { $0.trackers }.contains { $0.id == tracker?.id }
        
        if trackerExists {
            try? trackerStore.updateTracker(with: newTracker)
        } else {
            do {
                try trackerCategoryStore.createTrackerWithCategory(tracker: newTracker, with: newTitleCategory)
            } catch {
                self.showAlert(LocalizableKeys.createTrackerAlert)
            }
        }
        categories = trackerCategoryStore.categories
        filteredByDate(nil)
    }
}

// MARK: - TrackerCellDelegate
extension TrackerViewController: TrackerCellDelegate {
    func completedTracker(id: UUID, at indexPath: IndexPath) {
        let trackerRecord = TrackerRecord(id: id, date: datePicker.date)
        if datePicker.date > Date() {
            self.showAlert(LocalizableKeys.completedTrackersAlert)
        } else {
            completedTrackers.append(trackerRecord)
            do {
                try trackerRecordStore.createTrackerRecord(from: trackerRecord)
            } catch {
                assertionFailure("Enabled to add \(trackerRecord)")
            }
        }
        delegateStatistic?.completedTrackers = completedTrackers
        collectionView.reloadItems(at: [indexPath])
    }
    func uncompletedTracker(id: UUID, at indexPath: IndexPath) {
        let filteredTrackerRecord = completedTrackers.filter { trackerRecord in
            isSameTrackerRecord(trackerRecord, id: id)
        }
        completedTrackers.removeAll { trackerRecord in
            isSameTrackerRecord(trackerRecord, id: id)
        }
        filteredTrackerRecord.forEach { trackerRecord in
            do {
                try trackerRecordStore.deleteTrackerRecord(trackerRecord: trackerRecord)
            } catch {
                assertionFailure("Enabled to delete \(trackerRecord)")
            }
        }
        delegateStatistic?.completedTrackers = completedTrackers
        collectionView.reloadItems(at: [indexPath])
    }
}

// MARK: - FilterViewControllerProtocol
extension TrackerViewController: FiltersViewControllerProtocol {
    
    func filterAllTrackers() {
        filterShowAllTrackers()
        showBackgroundView(forCollection: true)
        filterAllTrackersIsTrue = true
    }
    func filterTrackersForToday() {
        filteredByDate(nil)
    }
    func filterCompletedTrackers() {
        filteredByDate(nil)
        filterCompletedTracker(date: datePicker.date)
    }
    func filterUnCompletedTrackers() {
        filteredByDate(nil)
        filterUncompletedTracker(date: datePicker.date)
    }
    
    // MARK: Filter methods
    func filterShowAllTrackers() {
        categories.forEach { trackerCategory in
            if trackerCategory.trackers.isEmpty {
                do {
                    try trackerCategoryStore.deleteCategory(with: trackerCategory.title)
                } catch {
                    assertionFailure("Enabled to delete \(trackerCategory)")
                }
            }
        }
        visibleCategories = categories
    }
    
    func filterCompletedTracker(date: Date) {
        visibleCategories = visibleCategories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                isTrackersCompletedToday(id: tracker.id, date: date)
            }
            if trackers.isEmpty { return nil }
            return TrackerCategory(title: category.title, trackers: trackers)
        }
        if visibleCategories.isEmpty {
            showBackgroundView(forCollection: true)
        }
    }
    
    func filterUncompletedTracker(date: Date) {
        visibleCategories = visibleCategories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                !isTrackersCompletedToday(id: tracker.id, date: date)
            }
            if trackers.isEmpty { return nil }
            return TrackerCategory(title: category.title, trackers: trackers)
        }
        if visibleCategories.isEmpty {
            showBackgroundView(forCollection: true)
        }
    }
    
    func isTrackersCompletedToday(id: UUID, date: Date) -> Bool {
        completedTrackers.contains { trackerRecord in
            isSameTrackersRecord(trackerRecord, id: id, date: date)
        }
    }
    func isSameTrackersRecord(_ record: TrackerRecord, id: UUID, date: Date) -> Bool {
        let isSameDay = Calendar.current.isDate(record.date, inSameDayAs: date)
        return record.id == id && isSameDay
    }
}

// MARK: - UICollectionViewDataSource
extension TrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifier, for: indexPath) as? TrackerCell else { return UICollectionViewCell()}
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        
        
        let isTrackerCompletedToday = isTrackerCompletedToday(id: tracker.id)
        let completedDays = completedTrackers.filter { $0.id == tracker.id }.count
        cell.setupCell(tracker: tracker, isCompletedToday: isTrackerCompletedToday, completedDays: completedDays, indexPath: indexPath)
        
        _ = pinnedTrackerCell(cell: cell, indexPath: indexPath, date: datePicker.date)
        cell.delegate = self
        return cell
    }
    
    private func isTrackerCompletedToday(id: UUID) -> Bool {
        completedTrackers.contains { trackerRecord in
            isSameTrackerRecord(trackerRecord, id: id)
        }
    }
    
    private func isSameTrackerRecord(_ record: TrackerRecord, id: UUID) -> Bool {
        let isSameDay = Calendar.current.isDate(record.date, inSameDayAs: datePicker.date)
        return record.id == id && isSameDay
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? HeaderViewCell else { return UICollectionReusableView()}
        view.titleLabel.text = visibleCategories[indexPath.section].title
        return view
    }
}

// MARK: - UICollectionViewDelegate
extension TrackerViewController: UICollectionViewDelegate & UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    // MARK: Context menu configuration
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfiguration configuration: UIContextMenuConfiguration,
                        highlightPreviewForItemAt indexPath: IndexPath) -> UITargetedPreview? {
        let targetView = configurationTargetView(indexPath: indexPath)
        return UITargetedPreview(view: targetView.0, parameters: targetView.1)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfiguration configuration: UIContextMenuConfiguration,
                        dismissalPreviewForItemAt indexPath: IndexPath) -> UITargetedPreview? {
        
        let targetView = configurationTargetView(indexPath: indexPath)
        return UITargetedPreview(view: targetView.0, parameters: targetView.1)
    }
    private func configurationTargetView(indexPath: IndexPath) -> (UIView, UIPreviewParameters) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell else { return (UIView(), UIPreviewParameters())}
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        let targetView = cell.colorView
        return (targetView, parameters)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemsAt indexPaths: [IndexPath],
                        point: CGPoint) -> UIContextMenuConfiguration? {
        guard indexPaths.count > 0 else { return nil }
        let indexPath = indexPaths[0]
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifier, for: indexPath) as? TrackerCell else { return nil }
        let pinned = pinnedTrackerCell(cell: cell, indexPath: indexPath, date: datePicker.date)
        pinTracker = !pinned
        
        let menu = UIMenu(
            children: [
                UIAction(title: pinTracker ? LocalizableKeys.pinTracker : LocalizableKeys.unpinTracker) { [weak self] _ in
                    guard let self else { return }
                    AnalyticsService.clickRecordTrackReport()
                    if self.pinTracker {
                        self.makePin(indexPath: indexPath)
                    } else {
                        self.makeUnpin(indexPath: indexPath)
                    }
                },
                UIAction(title: LocalizableKeys.editTracker) { [weak self] _ in
                    guard let self else { return }
                    AnalyticsService.editTrackReport()
                    self.makeEdit(indexPath: indexPath)
                },
                UIAction(title: LocalizableKeys.deleteTracker, image: nil, identifier: nil, discoverabilityTitle: nil, attributes: .destructive) {[weak self] _ in
                    guard let self else { return }
                    AnalyticsService.deleteTrackReport()
                    self.makeDelete(indexPath: indexPath)}
            ])
        
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            return menu
        }
        
        return configuration
    }
    private func makePin(indexPath: IndexPath) {
        pinOfTracker(indexPath: indexPath)
        filteredByDate(nil)
    }
    private func makeUnpin(indexPath: IndexPath) {
        unpinOfTracker(indexPath: indexPath)
        filteredByDate(nil)
    }
    private func makeEdit(indexPath: IndexPath) {
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        let category = visibleCategories[indexPath.section].title
        let daysCount = completedTrackers.filter { $0.id == tracker.id }.count
        
        let editViewController = NewTrackerViewController()
        
        if tracker.timetable?.isEmpty == true {
            let editEvent = LocalizableKeys.editingIrregularEvent
            editViewController.title = editEvent
            UserDefaultsManager.showIrregularEvent = true
        } else {
            let editHabit = LocalizableKeys.editingHabits
            editViewController.title = editHabit
            UserDefaultsManager.showIrregularEvent = false
        }
        
        editViewController.isEdit = true
        editViewController.currentTracker = tracker
        editViewController.editCategory = category
        editViewController.dayButtonToggled = isTrackerCompletedToday(id: tracker.id)
        editViewController.daysCount = daysCount
        editViewController.date = currentDate
        editViewController.onTrackerCreated = { [weak self] tracker, category in
            guard let self = self else { return }
            self.createTracker(tracker, titleCategory: category)
            self.isCompletedTracker()
            self.delegateStatistic?.completedTrackers = completedTrackers
        }
        
        let navigationController = UINavigationController(rootViewController: editViewController)
        navigationController.navigationBar.barTintColor = ColoursTheme.blackDayWhiteDay

        navigationController.navigationBar.shadowImage = UIImage()
        present(navigationController, animated: true)
    }
    private func makeDelete(indexPath: IndexPath) {
        showDeleteAlert(indexPath: indexPath)

    }
    
    private func showDeleteAlert(indexPath: IndexPath) {
        let alert = UIAlertController(title: nil, message: LocalizableKeys.showDeleteAlert, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: LocalizableKeys.deleteTracker, style: .destructive) { [weak self] _ in
            guard let self else { return }
            self.deletingOfTracker(indexPath: indexPath)
            if self.filterAllTrackersIsTrue {
                self.showBackgroundView(forCollection: true)
            } else {
                self.filteredByDate(nil)
                filterAllTrackersIsTrue = false
            }
        }
        let cencelAction = UIAlertAction(title: LocalizableKeys.searchBarCancel, style: .cancel)
        alert.addAction(deleteAction)
        alert.addAction(cencelAction)
        self.present(alert, animated: true)
    }
    
    // MARK: Pinned trackers cell
    func pinnedTrackerCell(cell: TrackerCell, indexPath: IndexPath, date: Date) -> Bool {
        let searchTracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        let pinnedTrackers = pinnedCategories.map { trackerCategory in
            trackerCategory.trackers
        }
        let isTrackerPinned = pinnedTrackers.compactMap { trackersArray in
            trackersArray.first { tracker in
                tracker.id == searchTracker.id
            }
        }
        var pinned = false
        isTrackerPinned.isEmpty ?  (pinned = false) :  (pinned = true)
        cell.setupPinned(tracker: searchTracker, isPinnedToday: pinned, indexPath: indexPath)
        return pinned
    }
    
    // MARK: Pin of tracker
    func pinOfTracker(indexPath: IndexPath) {
        let pinnedTracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        pinnedCategories.append(TrackerCategory(title: visibleCategories[indexPath.section].title, trackers: [pinnedTracker]))
//        trackerStore.deleteTracker(tracker: pinnedTracker)
        categories = trackerCategoryStore.categories
        let newTitleCategory = LocalizableKeys.pinnedTrackers
        let newCategory = TrackerCategory(title: newTitleCategory, trackers: [pinnedTracker])
        if categories.contains(where: { $0.title == newCategory.title }) {
            guard let index = categories.firstIndex(where: { $0.title == newCategory.title }) else { return }
            _ = categories[index]

        }
    }
    // MARK: unpin of tracker
    func unpinOfTracker(indexPath: IndexPath) {
        let pinnedTracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        
        guard let unpinnedTracker = pinnedCategories.compactMap({ trackerCategory in
            trackerCategory.trackers.first { tracker in
                tracker.id == pinnedTracker.id
            }
        }).first else { return }
        
        guard let titleCategory = pinnedCategories.filter({ trackerCategory in
            trackerCategory.trackers.contains { tracker in
                tracker.id == pinnedTracker.id
            }
        }).first?.title else { return }
        
        let oldCategory = TrackerCategory(title: titleCategory, trackers: [unpinnedTracker])
        if categories.contains(where: { $0.title == oldCategory.title }) {
            guard let index = categories.firstIndex(where: { $0.title == oldCategory.title }) else { return }
            let oldCategory = categories[index]
            let updatedTrackers = oldCategory.trackers
            let updatedTrackerCategory = TrackerCategory(title: oldCategory.title, trackers: updatedTrackers)
            categories[index] = updatedTrackerCategory
        } else {
            categories.append(oldCategory)
        }
        do {
            try trackerCategoryStore.createTrackerWithCategory(tracker: unpinnedTracker, with: titleCategory)
        } catch {
            assertionFailure("Enabled to add \(unpinnedTracker)")
        }
        trackerStore.deleteTracker(tracker: pinnedTracker)
        categories = trackerCategoryStore.categories
        
        pinnedCategories = pinnedCategories.compactMap { trackerCategory in
            let trackers = trackerCategory.trackers.filter { tracker in
                tracker.id != pinnedTracker.id
            }
            if trackers.isEmpty {
                return nil
            }
            return TrackerCategory(title: trackerCategory.title, trackers: trackers)
        }
    }
//    
    // MARK: Deleting of tracker
    func deletingOfTracker(indexPath: IndexPath) {
        let searchTracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        trackerStore.deleteTracker(tracker: searchTracker)
        trackerCategoryStore.categories.forEach { trackerCategory in
            if trackerCategory.trackers.isEmpty {
                do {
                    try trackerCategoryStore.deleteCategory(with: trackerCategory.title)
                } catch {
                    assertionFailure("Enabled to delete \(trackerCategory)")
                }
            }
        }
        categories = trackerCategoryStore.categories
        visibleCategories = categories
        
        completedTrackers = completedTrackers.filter {
            if $0.id == searchTracker.id {
                do {
                    try trackerRecordStore.deleteTrackerRecord(trackerRecord: $0)
                } catch {
                    assertionFailure("Enabled to delete \($0)")
                }
            }
            return $0.id != searchTracker.id
        }
        delegateStatistic?.completedTrackers = completedTrackers
    }
    
    private func isCompletedTracker() {
        visibleCategories.forEach { category in
            category.trackers.forEach { tracker in
                let isCompletedToday = completedTrackers.contains { recordTracker in
                    recordTracker.id == tracker.id && areDatesEqualIgnoringTime(date1: recordTracker.date, date2: currentDate)
                }
                isCompleteSelectedTracker[tracker.id] = isCompletedToday
            }
        }
    }
    
    private func areDatesEqualIgnoringTime(date1: Date, date2: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date1, equalTo: date2, toGranularity: .day)
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.bounds.width - params.paddingWidth
        let cellWidth = availableWidth / CGFloat(params.cellCount)
        return CGSize(width: cellWidth , height: cellWidth * 148/167)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: SizeCollectionView.betweenHeaderAndCell.rawValue, left: params.leftInset, bottom: SizeCollectionView.distanceBetweenCells.rawValue, right: params.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return params.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return SizeCollectionView.distanceBetweenCells.rawValue
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(
            collectionView,
            viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader,
            at: indexPath
        )
        
        return headerView.systemLayoutSizeFitting(CGSize(
            width: collectionView.frame.width,
            height: UIView.layoutFittingExpandedSize.height),
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: .fittingSizeLevel)
    }
}

//MARK: - UISearchBarDelegate
extension TrackerViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredByDate(searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filteredByDate(nil)
    }
    
    private func setupSearch() {
        searchController = UISearchController(searchResultsController: nil)
        searchController?.searchBar.delegate = self
        searchController?.obscuresBackgroundDuringPresentation = false
        searchController?.searchBar.placeholder = LocalizableKeys.searchBarPlaceholder
        
        navigationItem.searchController = searchController
        
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: ColoursTheme.whiteDayBlackDay,
        ]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attributes, for: .normal)
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = LocalizableKeys.searchBarCancel
        definesPresentationContext = true
    }
}

//MARK: - SetupViews
private extension TrackerViewController {
    func setupViews() {
        categories = trackerCategoryStore.categories
        visibleCategories = categories
        filteredCategoriesByDate = categories
        completedTrackers = trackerRecordStore.trackerRecords
        
        pinnedCategories = categories.filter { trackerCategory in
            trackerCategory.title == LocalizableKeys.pinnedTrackers
        }
        
        view.addSubviews(collectionView, filterButton)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            filterButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
