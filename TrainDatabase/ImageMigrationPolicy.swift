//
//  ImageMigrationPolicy.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 1/25/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import Foundation
import AppKit
import CoreData

@objc
final class ImageMigrationPolicy: NSEntityMigrationPolicy {

    @objc
    func imageDataFromFilename(_ filename: String?) -> Data? {
        guard let filename = filename else { return nil }

        let imagesURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!.appendingPathComponent("ModelImages", isDirectory: true)
        let imageURL = imagesURL.appendingPathComponent(filename)
        guard let image = NSImage(contentsOf: imageURL) else { return nil }

        guard let imageData = image.tiffRepresentation else { return nil }
        guard let imageRep = NSBitmapImageRep(data: imageData) else { return nil }
        guard let pngData = imageRep.representation(using: .png, properties: [:]) else { return nil }

        return pngData
    }
}
