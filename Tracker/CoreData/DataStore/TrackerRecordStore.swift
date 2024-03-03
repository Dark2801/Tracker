//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Андрей Мерзликин on 03.03.2024.
//

import UIKit
import CoreData

protocol TrackerRecordStoreDelegate: AnyObject {
    func storeRecord()
}

final class TrackerRecordStore: NSObject {
    enum TrackerErrors: Error {
        case missingRequiredValues
        case invalidInput
        case fetchError(Error)
        
    }
    
    private var context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>!
    
    weak var delegate: TrackerRecordStoreDelegate?
    
    var trackerRecords: [TrackerRecord] {
        guard
            let objects = self.fetchedResultsController.fetchedObjects,
            let records = try? objects.map({ try self.record(from: $0)})
        else { return [] }
        return records
    }
    
    convenience override init() {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.context {
            do {
                try self.init(context: context)
            } catch {
                assertionFailure("Failed to initialize TrackerRecordStore. Error: \(error)")
                self.init()  //TODO: Call the designated initializer with default behavior or handle it
            }
        } else {
            assertionFailure("Unable to obtain CoreData context.")
            self.init()  //TODO: Call the designated initializer with default behavior or handle it
        }
    }
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
        
        let fetch = TrackerRecordCoreData.fetchRequest()
        fetch.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerRecordCoreData.trackerId, ascending: true)
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
            throw TrackerErrors.fetchError(error)
        }
    }
    
    func addNewTrackerRecord(_ trackerRecord: TrackerRecord) throws {
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        trackerRecordCoreData.trackerId = trackerRecord.trackerId
        trackerRecordCoreData.date = trackerRecord.date
        try context.save()
    }
    
    func removeTrackerRecord(_ trackerRecord: TrackerRecord?) throws {
        guard let toDelete = try self.fetchTrackerRecord(with: trackerRecord)
        else {
            assertionFailure("Failed to fetch tracker record for deletion.")
            return
        }
        context.delete(toDelete)
        do {
            try context.save()
        } catch {
            assertionFailure("Failed to save context after deleting tracker record. Error: \(error)")
        }
        
    }
    
    func record(from trackerRecordCoreData: TrackerRecordCoreData) throws -> TrackerRecord {
        guard let id = trackerRecordCoreData.trackerId,
              let date = trackerRecordCoreData.date
        else {
            assertionFailure("Failed to create TrackerRecord from TrackerRecordCoreData. Missing required values.")
            throw TrackerErrors.missingRequiredValues
        }
        return TrackerRecord(trackerId: id, date: date)
    }
    
    func fetchTrackerRecord(with trackerRecord: TrackerRecord?) throws -> TrackerRecordCoreData? {
        guard let trackerRecord = trackerRecord else {
            throw TrackerErrors.invalidInput
        }
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "trackerId == %@", trackerRecord.trackerId as CVarArg)
        do {
            let result = try context.fetch(fetchRequest)
            return result.first
        } catch {
            throw TrackerErrors.fetchError(error)
        }
    }
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeRecord()
    }
}
