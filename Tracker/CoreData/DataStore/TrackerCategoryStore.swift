//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Андрей Мерзликин on 03.03.2024.
//

import UIKit
import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func storeCategory() -> Void
}

final class TrackerCategoryStore: NSObject {
    
    static let shared = TrackerCategoryStore()
    
    private var context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>!
    private let trackerStore = TrackerStore()
    
    weak var delegate: TrackerCategoryStoreDelegate?
    
    var trackerCategories: [TrackerCategory] {
        guard
            let objects = self.fetchedResultsController.fetchedObjects,
            let categories = try? objects.map({ try self.trackerCategory(from: $0)})
        else { return [] }
        return categories
    }
    
    convenience override init() {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.context else {
            assertionFailure("Unable to obtain CoreData context.")
            self.init()  // TODO: Call the designated initializer with default behavior or handle it
            return
        }

        do {
            try self.init(context: context)
        } catch {
            assertionFailure("Failed to initialize TrackerCategoryStore. Error: \(error)")
            self.init()  // TODO: Call the designated initializer with default behavior or handle it
        }
    }
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
        
        let fetch = TrackerCategoryCoreData.fetchRequest()
        fetch.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCategoryCoreData.title, ascending: true)
        ]
        let controller = NSFetchedResultsController(
            fetchRequest: fetch,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        self.fetchedResultsController = controller
        try controller.performFetch()
    }
    
    func addNewCategory(_ category: TrackerCategory) throws {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        trackerCategoryCoreData.title = category.title
        
        trackerCategoryCoreData.trackers = category.trackers.map {
            $0.id
        }
        try context.save()
    }
    
    func updateCategory(category: TrackerCategory?, header: String) throws {
        guard let fromDb = try self.fetchTrackerCategory(with: category) else { fatalError() }
        fromDb.title = header
        try context.save()
    }
    
    func addTrackerToCategory(to category: TrackerCategory?, tracker: Tracker) throws {
        guard let fromDb = try self.fetchTrackerCategory(with: category) else {
            assertionFailure("Failed to fetch the tracker category with title: \(String(describing: category))")
            return
        }
        fromDb.trackers = trackerCategories.first {
            $0.title == fromDb.title
        }?.trackers.map { $0.id }
        fromDb.trackers?.append(tracker.id)
        try context.save()
    }
    
    func deleteCategory(_ category: TrackerCategory?) throws {
        let toDelete = try fetchTrackerCategory(with: category)
        guard let toDelete = toDelete else { return }
        context.delete(toDelete)
        try context.save()
    }
    
    func trackerCategory(from trackerCategoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let title = trackerCategoryCoreData.title,
              let rawTrackers = trackerCategoryCoreData.trackers
        else {
            throw TrackerError.invalidTrackersType
        }
        
        let filteredTrackers = trackerStore.trackers.filter { tracker in
            let trackerID = tracker.id
            return rawTrackers.contains(trackerID)
        }
        
        return TrackerCategory(title: title, trackers: filteredTrackers)
    }
    
    func fetchTrackerCategory(with category: TrackerCategory?) throws -> TrackerCategoryCoreData? {
        guard let category = category else {
            throw TrackerError.invalidTitle
        }
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", category.title as CVarArg)
        let result = try context.fetch(fetchRequest)
        return result.first
    }
    
    enum TrackerError: Error {
        case invalidTrackersType
        case invalidTitle
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeCategory()
    }
}
