//
//  Model+Image.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/17/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

extension Model {

    static let imagesURL: URL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!.appendingPathComponent("ModelImages", isDirectory: true)

    var imageURL: URL? {
        guard let imageFilename = imageFilename else { return nil }
        return Model.imagesURL.appendingPathComponent(imageFilename)
    }

    public var image: ModelImage? {
        get {
            guard let imageURL = imageURL else { return nil }
            return ModelImage(contentsOf: imageURL)
        }

        set {
            if let imageURL = imageURL {
                do {
                    try FileManager.default.removeItem(at: imageURL)
                } catch CocoaError.fileNoSuchFile {
                    // Ignore, no matter how strange that is.
                    print("Failed to delete file that wasn't there: \(imageURL.lastPathComponent)")
                } catch {
                    print("Failed to delete \(imageURL.lastPathComponent): \(error)")
                }
            }

            imageFilename = nil

            if let image = newValue {
                imageFilename = UUID().uuidString + ".png"
                try! FileManager.default.createDirectory(at: Model.imagesURL, withIntermediateDirectories: true, attributes: nil)

                try! image.pngData()?.write(to: imageURL!)
            }
        }
    }

    public override func prepareForDeletion() {
        super.prepareForDeletion()

        if let imageURL = imageURL {
            do {
                try FileManager.default.removeItem(at: imageURL)
            } catch CocoaError.fileNoSuchFile {
                // Ignore, this is probably one context learning about the deletion of another.
            } catch {
                print("Failed to delete \(imageURL.lastPathComponent): \(error)")
            }
        }
    }

    @objc
    override class func willDeleteObjects(matching deleteRequest: NSFetchRequest<NSFetchRequestResult>, in context: NSManagedObjectContext) throws {
        // Create a new fetch request, with the same predicate; both remembering that deleteRequest
        // is a reference, and also that we only really care about the predicate.
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = self.fetchRequest()

        fetchRequest.predicate = deleteRequest.predicate
        fetchRequest.fetchBatchSize = 20
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.propertiesToFetch = [ "imageFilename" ]
        
        let results = try context.performAndWait {
            return try fetchRequest.execute() as! [[String: Any]]
        }

        for result in results {
            guard let imageFilename = result["imageFilename"] as? String else { continue }
            let imageURL = Model.imagesURL.appendingPathComponent(imageFilename)

            do {
                try FileManager.default.removeItem(at: imageURL)
            } catch CocoaError.fileNoSuchFile {
                // Ignore.
            } catch {
                print("Failed to delete \(imageURL.lastPathComponent): \(error)")
            }
        }
    }

}
