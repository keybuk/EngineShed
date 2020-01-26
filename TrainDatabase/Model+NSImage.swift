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

    func pngData() throws -> Data {
        guard let imageData = self.tiffRepresentation else { throw NSError() }
        guard let imageRep = NSBitmapImageRep(data: imageData) else { throw NSError() }
        guard let pngData = imageRep.representation(using: .png, properties: [:]) else { throw NSError() }
        return pngData
    }

    func saveAsPNG(to url: URL) throws {
        try pngData().write(to: url)
    }

}

    
extension Model {

    var imageData: Data? {
        get { managedObject.imageData }
        set {
            managedObject.imageData = newValue
            try? managedObject.managedObjectContext?.save() // FIXME!
        }
    }
    
    var image: NSImage? {
        get { managedObject.imageData.flatMap { NSImage(data: $0) } }
        set { managedObject.imageData = try? newValue?.pngData() }
    }
    
}
