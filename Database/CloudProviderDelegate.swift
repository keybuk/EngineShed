//
//  CloudProviderDelegate.swift
//  EngineShed
//
//  Created by Scott James Remnant on 1/3/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation
import CloudKit

/// Protocol used by `CloudProvider` to notify of conditions encountered during its operation.
public protocol CloudProviderDelegate {

    /// Called when records have been saved.
    func cloudProvider(_ cloudProvider: CloudProvider, didSaveRecords records: [CKRecord])

    /// Called when records have been deleted.
    func cloudProvider(_ cloudProvider: CloudProvider, didDeleteRecordsWithIDs recordIDs: [CKRecord.ID])

    /// Called when an error occurs.
    func cloudProvider(_ cloudProvider: CloudProvider, didFailWithError error: Error)

}

// Provide default implementations of the optional ones.
extension CloudProviderDelegate {

    public func cloudProvider(_ cloudProvider: CloudProvider, didSaveRecords records: [CKRecord]) {}

    public func cloudProvider(_ cloudProvider: CloudProvider, didDeleteRecordsWithIDs recordIDs: [CKRecord.ID]) {}

}
