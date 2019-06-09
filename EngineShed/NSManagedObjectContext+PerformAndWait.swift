//
//  NSManagedObjectContext+PerformAndWait.swift
//  EngineShed
//
//  Created by Scott James Remnant on 12/29/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import CoreData

// Copy the implementation of Dispatch.sync<T> with rethrows and return value support
// https://github.com/apple/swift/blob/bb157a070ec6534e4b534456d208b03adc07704b/stdlib/public/SDK/Dispatch/Queue.swift#L228-L249
extension NSManagedObjectContext {

    /// Synchronously performs a given block on the context’s queue.
    ///
    /// This variant allows `block` to return a value to the caller, and allows `block` to throw
    /// errors to be caught by the caller.
    ///
    /// - Parameter block: The block to perform.
    public func performAndWait<T>(_ block: () throws -> T) rethrows -> T {
        return try _performAndWaitHelper(
            fn: performAndWait, execute: block, rescue: { throw $0 }
        )
    }

    private func _performAndWaitHelper<T>(
        fn: (() -> Void) -> Void,
        execute work: () throws -> T,
        rescue: ((Error) throws -> (T))) rethrows -> T
    {
        var result: T?
        var error: Error?
        withoutActuallyEscaping(work) { _work in
            fn {
                do {
                    result = try _work()
                } catch let e {
                    error = e
                }
            }
        }
        if let e = error {
            return try rescue(e)
        } else {
            return result!
        }
    }

}
