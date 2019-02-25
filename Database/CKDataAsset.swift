//
//  CKDataAsset.swift
//  EngineShed
//
//  Created by Scott James Remnant on 2/25/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation
import CloudKit

/// CKDataAsset is a subclass of CKAsset that can be initialized with `Data`.
///
/// This manages a temporary file that lasts for the lifetime of the object.
class CKDataAsset : CKAsset {

    public var temporaryURL: URL

    init(data: Data) throws {
        let fileManager = FileManager.default
        let temporaryFilename = UUID().uuidString
        temporaryURL = fileManager.temporaryDirectory.appendingPathComponent(temporaryFilename)
        try data.write(to: temporaryURL)

        super.init(fileURL: temporaryURL)
    }

    deinit {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: temporaryURL)
        } catch {
            print("Error removing temporary file for CKAsset: \(error)")
        }
    }

}

