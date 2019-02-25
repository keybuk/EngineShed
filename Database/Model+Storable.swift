//
//  Model+Storable.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/17/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import CloudKit
import CoreData

extension Model : CloudStorable {

    /// CloudKit record type.
    static let recordType = "Model"

    /// Update list of relationship objects from a `CKRecord` list.
    ///
    /// Since Core Data has no concept of a string list, and to reduce the model burden on the
    /// Cloud Kit side, we translate between string lists and relationships with sets of
    /// objects that just contain a title.
    ///
    /// - Parameters:
    ///   - objects: set of objects in the relationship.
    ///   - titles: list of titles from CloudKit.
    ///   - as: type of `NSManagedObject` to construct.
    func updateList<Entity: NSManagedObject>(_ objects: NSSet?, from titles: [String]?, as type: Entity.Type) {
        guard let managedObjectContext = managedObjectContext else { preconditionFailure("Can't update list field outside of managed object context") }

        var newTitles = Set(titles ?? [])

        // Remove any database object not in `newTitles`, or any new title that's in the database.
        if let objects = objects as? Set<NSManagedObject> {
            for object in objects {
                guard let title = object.value(forKey: "title") as? String else { continue }
                if newTitles.contains(title) {
                    newTitles.remove(title)
                } else {
                    managedObjectContext.performAndWait {
                        object.setValue(nil, forKey: "model")
                        managedObjectContext.delete(object)
                    }
                }
            }
        }

        // Insert any title left in `newTitles`.
        for title in newTitles {
            let object = Entity(context: managedObjectContext)
            object.setValue(self, forKey: "model")
            object.setValue(title, forKey: "title")
        }
    }

    /// Update the managed object from a CloudKit record.
    ///
    /// - Parameters:
    ///   - record: CloudKit record to update from.
    func update(from record: CKRecord) throws {
        modelClass = record["class"]
        classificationRawValue = record["classification"] ?? 0
        details = record["details"]
        dispositionRawValue = record["disposition"] ?? 0
        eraRawValue = record["era"] ?? 0
        livery = record["livery"]
        motor = record["motor"]
        name = record["name"]
        notes = record["notes"]
        number = record["number"]
        socket = record["socket"]
        speaker = record["speaker"]

        if let asset = record["image"] as? CKAsset, let fileURL = asset.fileURL {
            imageData = try? Data(contentsOf: fileURL)
        } else {
            imageData = nil
        }

        if let data = record["lastOil"] as? Data,
            let unarchiver = try? NSKeyedUnarchiver(forReadingFrom: data)
        {
            lastOil = unarchiver.decodeObject(of: NSDateComponents.self, forKey: "LastOil")
            unarchiver.finishDecoding()
        }
        
        if let data = record["lastRun"] as? Data,
            let unarchiver = try? NSKeyedUnarchiver(forReadingFrom: data)
        {
            lastRun = unarchiver.decodeObject(of: NSDateComponents.self, forKey: "LastRun")
            unarchiver.finishDecoding()
        }

        updateList(couplings, from: record["couplings"], as: Coupling.self)
        updateList(detailParts, from: record["detailParts"], as: DetailPart.self)
        updateList(features, from: record["features"], as: Feature.self)
        updateList(fittedDetailParts, from: record["fittedDetailParts"], as: FittedDetailPart.self)
        updateList(lights, from: record["lights"], as: Light.self)
        updateList(modifications, from: record["modifications"], as: Modification.self)
        updateList(speakerFittings, from: record["speakerFittings"], as: SpeakerFitting.self)
        updateList(tasks, from: record["tasks"], as: Task.self)

        if let reference = record["purchase"] as? CKRecord.Reference {
            purchase = try Purchase.objectForRecordID(reference.recordID, in: managedObjectContext!)
        } else {
            purchase = nil
        }
    }

    /// Update a CloudKit record from this managed object.
    ///
    /// - Parameters:
    ///   - record: CloudKit record to update.
    ///   - keys: update only these keys (managed object name), or all keys if `nil.
    func updateRecord(_ record: CKRecord, forKeys keys: Set<String>?) {
        if keys?.contains("modelClass") ?? true { record["class"] = modelClass }
        if keys?.contains("classificationRawValue") ?? true { record["classification"] = classificationRawValue }
        if keys?.contains("details") ?? true { record["details"] = details }
        if keys?.contains("dispositionRawValue") ?? true { record["disposition"] = dispositionRawValue }
        if keys?.contains("eraRawValue") ?? true { record["era"] = eraRawValue }
        if keys?.contains("livery") ?? true { record["livery"] = livery }
        if keys?.contains("motor") ?? true { record["motor"] = motor }
        if keys?.contains("name") ?? true { record["name"] = name }
        if keys?.contains("notes") ?? true { record["notes"] = notes }
        if keys?.contains("number") ?? true { record["number"] = number }
        if keys?.contains("socket") ?? true { record["socket"] = socket }
        if keys?.contains("speaker") ?? true { record["speaker"] = speaker }

        if keys?.contains("imageFilename") ?? true {
            record["image"] = imageData.flatMap { (imageData) -> CKAsset? in
                do {
                    return try CKDataAsset(data: imageData)
                } catch {
                    print("Error creating CKAsset for data: \(error)")
                    return nil
                }
            }
        }

        if keys?.contains("lastOil") ?? true {
            record["lastOil"] = lastOil.map {
                let archiver = NSKeyedArchiver(requiringSecureCoding: true)
                archiver.encode($0, forKey: "LastOil")
                archiver.finishEncoding()
                return archiver.encodedData as NSData
            }
        }
        
        if keys?.contains("lastRun") ?? true {
            record["lastRun"] = lastRun.map {
                let archiver = NSKeyedArchiver(requiringSecureCoding: true)
                archiver.encode($0, forKey: "LastRun")
                archiver.finishEncoding()
                return archiver.encodedData as NSData
            }
        }

        if keys?.contains("couplings") ?? true {
            if let couplings = couplings as? Set<Coupling> {
                record["couplings"] = couplings.compactMap { $0.title }
            } else {
                record["couplings"] = nil
            }
        }

        if keys?.contains("detailParts") ?? true {
            if let detailParts = detailParts as? Set<DetailPart> {
                record["detailParts"] = detailParts.compactMap { $0.title }
            } else {
                record["detailParts"] = nil
            }
        }

        if keys?.contains("features") ?? true {
            if let features = features as? Set<Feature> {
                record["features"] = features.compactMap { $0.title }
            } else {
                record["features"] = nil
            }
        }

        if keys?.contains("fittedDetailParts") ?? true {
            if let fittedDetailParts = fittedDetailParts as? Set<FittedDetailPart> {
                record["fittedDetailParts"] = fittedDetailParts.compactMap { $0.title }
            } else {
                record["fittedDetailParts"] = nil
            }
        }

        if keys?.contains("lights") ?? true {
            if let lights = lights as? Set<Light> {
                record["lights"] = lights.compactMap { $0.title }
            } else {
                record["lights"] = nil
            }
        }

        if keys?.contains("modifications") ?? true {
            if let modifications = modifications as? Set<Modification> {
                record["modifications"] = modifications.compactMap { $0.title }
            } else {
                record["modifications"] = nil
            }
        }

        if keys?.contains("speakerFittings") ?? true {
            if let speakerFittings = speakerFittings as? Set<SpeakerFitting> {
                record["speakerFittings"] = speakerFittings.compactMap { $0.title }
            } else {
                record["speakerFittings"] = nil
            }
        }

        if keys?.contains("tasks") ?? true {
            if let tasks = tasks as? Set<Task> {
                record["tasks"] = tasks.compactMap { $0.title }
            } else {
                record["tasks"] = nil
            }
        }

        if keys?.contains("purchase") ?? true {
            if let recordID = purchase?.recordID {
                record["purchase"] = CKRecord.Reference(recordID: recordID, action: .deleteSelf)
            } else {
                record["purchase"] = nil
            }
        }
    }

}
