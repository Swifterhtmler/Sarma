
# SwiftData Quick Reference

## Create a Model
```swift
import SwiftData
import Foundation

@Model
final class MyThing {
    var name: String
    var count: Int
    
    init(name: String, count: Int) {
        self.name = name
        self.count = count
    }
}
```

## Register in App
```swift
.modelContainer(for: [MyThing.self])
```

## Use in View
```swift
@Environment(\.modelContext) private var modelContext
@Query private var things: [MyThing]

// Create
let item = MyThing(name: "test", count: 1)
modelContext.insert(item)

// Update
item.name = "new name"

// Delete
modelContext.delete(item)
```

## Common Property Types
- `String` - text
- `Int` - whole numbers
- `Double` - decimals
- `Date` - dates
- `Bool` - true/false
- `String?` - optional text (can be nil)
