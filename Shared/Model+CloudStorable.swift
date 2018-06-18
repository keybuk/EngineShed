//
//  Model+CloudStorable.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/17/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import CloudKit
import CoreData

extension Model : CloudStorable {

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

        // The detailPartsFitted field is a subset of detailParts, which is updated above, so we
        // update it by checking the set of objects that need to have isFitted changed.
        if let detailParts = detailParts as? Set<DetailPart> {
            if let detailPartsFitted = record["detailPartsFitted"] as? [String] {
                for detailPart in detailParts {
                    detailPart.isFitted = detailPartsFitted.contains(detailPart.title ?? "")
                }
            } else {
                for detailPart in detailParts { detailPart.isFitted = false }
            }
        }

        if let reference = record["purchase"] as? CKRecord.Reference {
            purchase = try Purchase.forRecordID(reference.recordID, in: managedObjectContext!)
        } else {
            purchase = nil
        }
    }

}
