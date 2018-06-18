//
//  Model+Image.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/17/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import Foundation

extension Model {

    private var imagesURL: URL {
        return FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!.appendingPathComponent("ModelImages", isDirectory: true)
    }

    internal var imageURL: URL? {
        guard let imageFilename = imageFilename else { return nil }
        return imagesURL.appendingPathComponent(imageFilename)
    }

    public var image: ModelImage? {
        get {
            guard let imageURL = imageURL else { return nil }
            return ModelImage(contentsOf: imageURL)
        }

        set {
            if let imageURL = imageURL {
                try! FileManager.default.removeItem(at: imageURL)
            }

            imageFilename = nil

            if let image = newValue {
                imageFilename = UUID().uuidString + ".png"
                try! FileManager.default.createDirectory(at: imagesURL, withIntermediateDirectories: true, attributes: nil)

                try! image.pngData()?.write(to: imageURL!)
            }
        }
    }

    public override func prepareForDeletion() {
        super.prepareForDeletion()

        if let imageURL = imageURL {
            try! FileManager.default.removeItem(at: imageURL)
            imageFilename = nil
        }
    }

}
