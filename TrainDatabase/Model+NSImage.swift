//
//  Model+Image.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 12/12/17.
//  Copyright © 2017 Scott James Remnant. All rights reserved.
//

import Cocoa
import CoreData

private extension NSImage {

    func saveAsPNG(to url: URL) throws {
        guard let imageData = self.tiffRepresentation else { throw NSError() }
        guard let imageRep = NSBitmapImageRep(data: imageData) else { throw NSError() }
        guard let pngData = imageRep.representation(using: .png, properties: [:]) else { throw NSError() }
        try pngData.write(to: url)
    }

}

    
extension Model {
    
    private var imagesURL: URL {
        return FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!.appendingPathComponent("ModelImages", isDirectory: true)
    }
    
    var imageURL: URL? {
        guard let imageFilename = imageFilename else { return nil }
        return imagesURL.appendingPathComponent(imageFilename)
    }
    
    var image: NSImage? {
        get {
            guard let imageURL = imageURL else { return nil }
            return NSImage(contentsOf: imageURL)
        }
        
        set {
            if let imageURL = imageURL {
                try! FileManager.default.removeItem(at: imageURL)
            }
            
            imageFilename = nil
            
            if let image = newValue {
                imageFilename = UUID().uuidString
                try! image.saveAsPNG(to: imageURL!)
            }
        }
    }
    
}
