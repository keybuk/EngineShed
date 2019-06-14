## General

Use `precondition` and `preconditionFailure` to stop progress beyond a point.
Use `assert` and `assertionFailure` only when it's okay to proceed in Release mode, but is something we want to catch in Debug mode just in case.
Use `fatalError` when we have an actual error, and always log it.

## Cocoa Touch

Properties initialized by constructor come first
Followed by outlets as weak IUOs
Followed by any properties set by segue or before loading the view

## Core Data

Treat `persistentContainer.viewContext` read-only, use for UI and fetch requests, not editing.
 • Since this is on the main queue, no need to use `context.perform`.
 • Guard observer and notification callbacks with a check we're still on the main queue:
```
    dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
```

Perform any changes in a background context and save.

Edit views should use a new context that uses the main queue, while saving changes back to the store:
```
// Use a read-write main queue context that saves to the store. In case of changes to the
// store (e.g. from sync or save in other window), merge but keep any local changes.
managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
managedObjectContext!.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
managedObjectContext!.automaticallyMergesChangesFromParent = true
managedObjectContext!.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
```
• Since this is on the main queue, no need to use `context.perform`.
• Guard observer and notification callbacks with a check we're still on the main queue:
```
dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
``` 

Always execute fetch requests inside a context queue
```
let results = try context.performAndWait {
return try fetchRequest.execute()
}
```    


Always create and delete objects inside a `context.perform` block

It's okay to call setters outside a background context's perform

`NSSet`, `NSOrderedSet`, etc. members are always force-unwrapped
