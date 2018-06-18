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
    ///   - values: set of titles from CloudKit.
    ///
    /// - Returns: (`newValues`, `removeObjects`) where `newValues` contains the set of titles
    ///   from `values` that were not present in the relationship, and `removeObjects` contains the
    ///   set of objects from `objects` that were not present in the title list.
    private func differencesFrom(objects: NSSet?, to values: Set<String>) -> (Set<String>, NSSet) {
        if let objects = objects as? Set<NSManagedObject> {
            let removeObjects = objects.filter {
                guard let title = $0.value(forKey: "title") as? String else { return true }
                return !values.contains(title)
                } as NSSet

            let newValues = values.subtracting(objects.map {
                guard let title = $0.value(forKey: "title") as? String else { return "" }
                return title
            })

            return (newValues, removeObjects)
        } else {
            return (values, [])
        }
    }

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
            let (newValues, removeObjects) = differencesFrom(objects: objects, to: Set(values))

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

        let (insertFeatures, removeFeatures) = differencesFrom(objects: features, to: record, key: "features", as: Feature.self)
        addToFeatures(insertFeatures)
        removeFromFeatures(removeFeatures)

        // FIXME: rename the schema "lighting" to "lights
        let (insertLights, removeLights) = differencesFrom(objects: lights, to: record, key: "lighting", as: Light.self)
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

        // Handle the split detailParts/detailPartsFitted field.
        // FIXME: evalulate whether maintaining this split is the best way to handle this, or if we should just have `DetailPart` and `DetailPartFitted` on this side.
        let newDetailParts: Set<String>
        if let values = record["detailParts"] as? [String] {
            newDetailParts = Set(values)
        } else {
            newDetailParts = []
        }

        let newDetailPartsFitted: Set<String>
        if let values = record["detailPartsFitted"] as? [String] {
            newDetailPartsFitted = Set(values)
        } else {
            newDetailPartsFitted = []
        }

        let (newValues, removeDetailParts) = differencesFrom(objects: detailParts, to: newDetailParts.union(newDetailPartsFitted))

        let insertDetailParts = Set(newValues.map { (title: String) -> DetailPart in
            let detailPart = DetailPart(context: managedObjectContext!)
            detailPart.title = title
            detailPart.isFitted = newDetailPartsFitted.contains(title)
            return detailPart
        }) as NSSet

        addToDetailParts(insertDetailParts)
        removeFromDetailParts(removeDetailParts)

        if let _ = record["purchase"] as? CKRecord.Reference {
            // TODO: purchase from CKReference
        } else {
            purchase = nil
        }
    }

}
