//
//  TrackerStore.swift
//  Tracker
//
//  Created by Андрей Мерзликин on 03.03.2024.
//

import UIKit
import CoreData

protocol TrackerStoreDelegate: AnyObject {
    func store() -> Void
}

final class TrackerStore: NSObject {
    enum TrackerError: Error {
        case invalidTrackerCoreData
        case invalidScheduleValue(Int)
        case fetchError(Error)
    }
    
    private var context: NSManagedObjectContext
  
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>!
    
    weak var delegate: TrackerStoreDelegate?
    
    var trackers: [Tracker] {
        guard
            let objects = self.fetchedResultsController.fetchedObjects,
            let trackers = try? objects.map({ try self.tracker(from: $0)})
        else { return [] }
        return trackers
    }
    
    convenience override init() {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.context {
            do {
                try self.init(context: context)
            } catch {
                assertionFailure("Failed to initialize TrackerRecordStore. Error: \(error)")
                self.init()
            }
        } else {
            assertionFailure("Unable to obtain CoreData context.")
            self.init()
        }
    }
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
        
        let fetch = TrackerCoreData.fetchRequest()
        fetch.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.id, ascending: true)
        ]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetch,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        controller.delegate = self
        self.fetchedResultsController = controller
        
        do {
            try controller.performFetch()
        } catch {
            throw TrackerError.fetchError(error)
        }
    }
    
    
    func addNewTracker(_ tracker: Tracker) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = UIColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.emoji = tracker.emoji
        
        trackerCoreData.schedule = tracker.schedule?.map {
            $0.rawValue
        }
        trackerCoreData.colorIndex = Int16(tracker.colorIndex)
        try context.save()
    }
    
    func updateTracker(_ tracker: Tracker, oldTracker: Tracker?) throws {
        let updated = try fetchTracker(with: oldTracker)
        guard let updated = updated else { return }
        updated.name = tracker.name
        updated.colorIndex = Int16(tracker.colorIndex)
        updated.color = UIColorMarshalling.hexString(from: tracker.color)
        updated.emoji = tracker.emoji
        updated.schedule = tracker.schedule?.map {
            $0.rawValue
        }
        try context.save()
    }
    
    func tracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard let id = trackerCoreData.id,
              let emoji = trackerCoreData.emoji,
              let color = UIColorMarshalling.color(from: trackerCoreData.color ?? ""),
              let name = trackerCoreData.name,
              let scheduleArray = trackerCoreData.schedule
        else {
            throw TrackerError.invalidTrackerCoreData
        }
        
        return Tracker(
            id: id,
            name: name,
            color: color,
            emoji: emoji,
            schedule: scheduleArray.map({ TrackerSchedule.DaysOfTheWeek(rawValue: $0)!}),
            pinned: trackerCoreData.pinned,
            colorIndex: Int(trackerCoreData.colorIndex), isCompleted: false
        )
    }
    
    func deleteTracker(_ tracker: Tracker?) throws {
        let toDelete = try fetchTracker(with: tracker)
        guard let toDelete = toDelete else { return }
        context.delete(toDelete)
        try context.save()
    }
    
    func pinTracker(_ tracker: Tracker?, value: Bool) throws {
        let toPin = try fetchTracker(with: tracker)
        guard let toPin = toPin else { return }
        toPin.pinned = value
        try context.save()
    }
    
    func fetchTracker(with tracker: Tracker?) throws -> TrackerCoreData? {
        guard let tracker = tracker else { fatalError() }
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        let result = try context.fetch(fetchRequest)
        return result.first
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.store()
    }
}
