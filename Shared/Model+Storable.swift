//
//  Model+Storable.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/17/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import CloudKit
import CoreData

extension Model : StorableManagedObject {

    /// CloudKit record type.
    static let recordType = "Model"

    /// Identify the differences from relationship objects to a `CKRecord` list.
    ///
    /// Since Core Data has no concept of a string list, and to reduce the model burden on the
    /// Cloud Kit side, we have to translate between string lists and relationships with sets of
    /// objects that just contain a title.
    ///
    /// - Parameters:
    ///   - objects: set of objects in the relationship.
    ///   - record: CloudKit record.
    ///   - key: key of field in CloudKit.
    ///   - as: type of `NSManagedObject` to construct.
    ///
    /// - Returns: (`insertObjects`, `removeObjects`) where `insertObjects` contains new objects
    ///   matching the titles in `record` that were not present in the relationship, and
    ///   `removeObjects` contains the set of objects from `objects` that were not present in
    ///   `record`.
    private func differencesFrom<T : NSManagedObject>(objects: NSSet?, to record: CKRecord, key: String, as type: T.Type) -> (NSSet, NSSet) {
        if let values = record[key] as? [String] {
            var removeObjects = NSSet()
            var newValues = Set(values)
            if let objects = objects as? Set<NSManagedObject> {
                removeObjects = objects.filter {
                    guard let title = $0.value(forKey: "title") as? String else { return true }
                    return !newValues.contains(title)
                } as NSSet

                newValues.subtract(objects.map {
                    guard let title = $0.value(forKey: "title") as? String else { return "" }
                    return title
                })
            }

            let insertObjects = Set(newValues.map { (title: String) -> T in
                let object = T(context: managedObjectContext!)
                object.setValue(title, forKey: "title")
                return object
            }) as NSSet

            return (insertObjects, removeObjects)
        } else {
            return ([], objects ?? [])
        }
    }

    /// Update the managed object from a CloudKit record.
    ///
    /// - Parameters:
    ///   - record: CloudKit record to update from.
    internal func update(from record: CKRecord) throws {
        modelClass = record["class"]
        classificationRawValue = record["classification"] ?? 0
        details = record["details"]
        dispositionRawValue = record["disposition"] ?? 0
        eraRawValue = record["era"] ?? 0
        lastOil = record["lastOil"]
        lastRun = record["lastRun"]
        livery = record["livery"]
        motor = record["motor"]
        name = record["name"]
        notes = record["notes"]
        number = record["number"]
        socket = record["socket"]
        speaker = record["speaker"]

        if let asset = record["image"] as? CKAsset {
            image = ModelImage(contentsOf: asset.fileURL)
        } else {
            image = nil
        }

        let (insertCouplings, removeCouplings) = differencesFrom(objects: couplings, to: record, key: "couplings", as: Coupling.self)
        addToCouplings(insertCouplings)
        removeFromCouplings(removeCouplings)

        let (insertDetailParts, removeDetailParts) = differencesFrom(objects: detailParts, to: record, key: "detailParts", as: DetailPart.self)
        addToDetailParts(insertDetailParts)
        removeFromDetailParts(removeDetailParts)

        let (insertFeatures, removeFeatures) = differencesFrom(objects: features, to: record, key: "features", as: Feature.self)
        addToFeatures(insertFeatures)
        removeFromFeatures(removeFeatures)

        let (insertFittedDetailParts, removeFittedDetailParts) = differencesFrom(objects: fittedDetailParts, to: record, key: "fittedDetailParts", as: FittedDetailPart.self)
        addToFittedDetailParts(insertFittedDetailParts)
        removeFromFittedDetailParts(removeFittedDetailParts)

        let (insertLights, removeLights) = differencesFrom(objects: lights, to: record, key: "lights", as: Light.self)
        addToLights(insertLights)
        removeFromLights(removeLights)

        let (insertModifications, removeModifications) = differencesFrom(objects: modifications, to: record, key: "modifications", as: Modification.self)
        addToModifications(insertModifications)
        removeFromModifications(removeModifications)

        let (insertSpeakerFittings, removeSpeakerFittings) = differencesFrom(objects: speakerFittings, to: record, key: "speakerFittings", as: SpeakerFitting.self)
        addToSpeakerFittings(insertSpeakerFittings)
        removeFromSpeakerFittings(removeSpeakerFittings)

        let (insertTasks, removeTasks) = differencesFrom(objects: tasks, to: record, key: "tasks", as: Task.self)
        addToTasks(insertTasks)
        removeFromTasks(removeTasks)

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
    internal func updateRecord(_ record: CKRecord, forKeys keys: Set<String>?) {
        if keys?.contains("modelClass") ?? true { record["class"] = modelClass }
        if keys?.contains("classificationRawValue") ?? true { record["classification"] = classificationRawValue }
        if keys?.contains("details") ?? true { record["details"] = details }
        if keys?.contains("dispositionRawValue") ?? true { record["disposition"] = dispositionRawValue }
        if keys?.contains("eraRawValue") ?? true { record["era"] = eraRawValue }
        if keys?.contains("lastOil") ?? true { record["lastOil"] = lastOil }
        if keys?.contains("lastRun") ?? true { record["lastRun"] = lastRun }
        if keys?.contains("livery") ?? true { record["livery"] = livery }
        if keys?.contains("motor") ?? true { record["motor"] = motor }
        if keys?.contains("name") ?? true { record["name"] = name }
        if keys?.contains("notes") ?? true { record["notes"] = notes }
        if keys?.contains("number") ?? true { record["number"] = number }
        if keys?.contains("socket") ?? true { record["socket"] = socket }
        if keys?.contains("speaker") ?? true { record["speaker"] = speaker }

        if keys?.contains("imageFilename") ?? true {
            if let imageURL = imageURL {
                record["image"] = CKAsset(fileURL: imageURL)
            } else {
                record["image"] = nil
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
