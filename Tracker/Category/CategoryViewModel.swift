//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Андрей Мерзликин on 03.03.2024.
//

final class CategoryViewModel {
    
    static let shared = CategoryViewModel()
    private var categoryStore = TrackerCategoryStore.shared
    private (set) var categories: [TrackerCategory] = []
    
    @Observable
    private (set) var selectedCategory: TrackerCategory?
    
    init() {
        categoryStore.delegate = self
        self.categories = categoryStore.trackerCategories
    }
    
    func addCategory(_ toAdd: String) {
        try? self.categoryStore.addNewCategory(TrackerCategory(title: toAdd, trackers: []))
    }
    
    func updateCategory(category: TrackerCategory?, header: String) {
        try? self.categoryStore.updateCategory(category: category, header: header)
    }
    
    func addTrackerToCategory(to category: TrackerCategory?, tracker: Tracker) {
        try? self.categoryStore.addTrackerToCategory(to: category, tracker: tracker)
    }
    
    func selectCategory(_ at: Int) {
        self.selectedCategory = self.categories[at]
    }
}

extension CategoryViewModel: TrackerCategoryStoreDelegate {
    func storeCategory() {
        self.categories = categoryStore.trackerCategories
    }
}
