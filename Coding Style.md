## General

Use `precondition` and `preconditionFailure` to stop progress beyond a point.
Use `assert` and `assertionFailure` only when it's okay to proceed in Release mode, but is something we want to catch in Debug mode just in case.
Use `fatalError` when we have an actual error, and always log it.

## Cocoa Touch

Properties initialized by constructor come first
Followed by outlets as weak IUOs
Followed by any properties set by segue or before loading the view

## Core Data

Always execute fetch requests inside a context queue
 ```
let results = try context.performAndWait {
    return try fetchRequest.execute()
}
```    

Treat `persistentContainer.viewContext` read-only, use for UI and fetch requests, not editing

Perform all editing in a background context and save

Always create and delete objects inside a `context.perform` block

It's okay to call setters outside a background context's perform

`NSSet`, `NSOrderedSet`, etc. members are always force-unwrapped
