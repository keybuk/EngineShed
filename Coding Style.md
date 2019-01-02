## Cocoa Touch

Properties initialized by constructor come first
Followed by outlets as weak IUOs
Followed by any properties set by segue or before loading the view
 - Managed object context is always optional

## Core Data

Always execute fetch requests inside a context queue
 ```
let results = context.performAndWait {
    return try fetchRequest.execute()
}
```    

Always create and delete objects inside a context queue

It's okay to call setters outside a context queue
