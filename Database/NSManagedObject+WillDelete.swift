//
//  NSManagedObject+WillDelete.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/21/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import CoreData

// Extend NSManagedObject to support custom delete handling during batch operations.
extension NSManagedObject {

    @objc
    class func willDeleteObjects(matching deleteRequest: NSFetchRequest<NSFetchRequestResult>, in context: NSManagedObjectContext) throws {}
}

