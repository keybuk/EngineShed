//
//  SearchViewController.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 1/30/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import Cocoa

struct FilterMember : SearchQuery {
    
    var name: String
    var predicate: NSPredicate { return NSPredicate() }
    
}

struct SearchGroup : SearchQuery {
    
    var op: Int
    var queries: [SearchQuery]
    var predicate: NSPredicate { return NSPredicate() }

}


extension NSUserInterfaceItemIdentifier {
    
    static let searchGroupCell = NSUserInterfaceItemIdentifier("searchGroupCell")
    static let textSearchCell = NSUserInterfaceItemIdentifier("textSearchCell")
    static let lookupSearchCell = NSUserInterfaceItemIdentifier("lookupSearchCell")
    static let integerSearchCell = NSUserInterfaceItemIdentifier("integerSearchCell")
    static let dateSearchCell = NSUserInterfaceItemIdentifier("dateSearchCell")
    static let currencySearchCell = NSUserInterfaceItemIdentifier("currencySearchCell")
    static let boolSearchCell = NSUserInterfaceItemIdentifier("boolSearchCell")
    static let relationSearchCell = NSUserInterfaceItemIdentifier("relationSearchCell")
    static let tableSearchCell = NSUserInterfaceItemIdentifier("tableSearchCell")

}

private extension NSPasteboard.PasteboardType {
    
    static let searchQuery = NSPasteboard.PasteboardType("com.netsplit.TrainDatabase.SearchQuery")
    
}

class SearchOutlineView : NSOutlineView {
    
    override func drawGrid(inClipRect clipRect: NSRect) {
    }
    
//    override func frameOfOutlineCell(atRow row: Int) -> NSRect {
//        return .zero
//    }
//
//    override func level(forRow row: Int) -> Int {
//        let level = super.level(forRow: row)
//        print("Super said level of row \(row) was \(level)")
//        return level
//    }
//
//    override func level(forItem item: Any?) -> Int {
//        let level = super.level(forItem: item)
//        print("Super said level of \(String(describing: item)) was \(level)")
//        return level
//    }
    
//    override func frameOfCell(atColumn column: Int, row: Int) -> NSRect {
//        var frame = super.frameOfCell(atColumn: column, row: row)
//
////        let indexes = dataSource?.tableView?(self, objectValueFor: nil, row: row) as? [Int]
////        let level = CGFloat(indexes?.count ?? 0)
////
////        frame.origin.x += SearchTableView.indentationPerLevel * level
////        frame.size.width -= SearchTableView.indentationPerLevel * level
//
//        frame.origin.x -= indentationPerLevel
//        frame.size.width += indentationPerLevel
//
//        return frame
//    }

}

class SearchViewController: NSViewController {
    
    @IBOutlet var nameTextField: NSTextField!
    @IBOutlet var outlineView: NSOutlineView!
    
    var search: SearchGroup!

    override func viewDidLoad() {
        super.viewDidLoad()

        outlineView.registerForDraggedTypes([ .searchQuery ])
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        if search == nil {
            var group = SearchGroup(op: 0, queries: [])
            
            group.queries.append(FilterMember(name: "One"))
            group.queries.append(FilterMember(name: "Two"))
            group.queries.append(SearchGroup(op: 1, queries: [ FilterMember(name: "Three"), FilterMember(name: "Four") ]))
            group.queries.append(FilterMember(name: "Five"))
            
            search = group
            
            outlineView.reloadData()
            outlineView.expandItem(nil, expandChildren: true)
        }
    }
    
    func indexes(for group: SearchGroup, at base: [Int]) -> [[Int]] {
        var result: [[Int]] = [base]
        
        for (index, query) in group.queries.enumerated() {
            if let subgroup = query as? SearchGroup {
                result.append(contentsOf: indexes(for: subgroup, at: base + [index]))
            } else {
                result.append(base + [index])
            }
        }
        
        return result
    }
    
    func itemAt(_ indexes: [Int]) -> SearchQuery {
        var thing: SearchQuery = search
        for subindex in indexes {
            guard let group = thing as? SearchGroup else { fatalError("Wasn't a group") }
            thing = group.queries[subindex]
        }
        return thing
    }

//    func keyPathsFor(_ group: FilterGroup, baseKeyPath: AnyKeyPath) -> [AnyKeyPath] {
//        var keyPaths: [AnyKeyPath] = []
//
//        keyPaths.append(baseKeyPath)
//
////        for (index, thing) in group.things.enumerated() {
////            if let subgroup = thing as? FilterGroup {
////                WritableKeyPath
////                baseKeyPath.appending(path: \FilterGroup.things[index])
////
////                keyPathsFor(subgroup, baseKeyPath: <#T##AnyKeyPath#>)
////            } else {
////
////            }
////        }
//
//        return keyPaths
//    }
    
}

extension SearchViewController : NSOutlineViewDataSource {
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        switch item {
        case nil:
            return search == nil ? 0 : 1
        case let indexes as [Int]:
            if let group = itemAt(indexes) as? SearchGroup {
                return group.queries.count
            } else {
                return 0
            }
        default:
            return 0
        }
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        switch item {
        case nil: return true
        case let indexes as [Int]:
            return itemAt(indexes) is SearchGroup
        default: return false
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        switch item {
        case nil:
            return []
        case let indexes as [Int]:
            return indexes + [ index ]
        default:
            fatalError("Item has no children")
        }
    }

    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        return item
    }

    func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
        let pasteboardItem = NSPasteboardItem()
        pasteboardItem.setString(String(describing: item), forType: .searchQuery)
        return pasteboardItem
    }

    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
        guard let _ = item else { return [] }
        guard index >= 0 else { return [] }
        return .move
    }

    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
        return false
    }
    
}

extension SearchViewController : NSOutlineViewDelegate {
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        switch item {
        case let indexes as [Int]:
            if itemAt(indexes) is SearchGroup {
                return 21
            } else {
                return 23
            }
        default: return 23
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        switch item {
        case let indexes as [Int]:
            if itemAt(indexes) is SearchGroup {
                return outlineView.makeView(withIdentifier: .searchGroupCell, owner: self)
            } else {
                return outlineView.makeView(withIdentifier: .lookupSearchCell, owner: self)
            }
        default:
            fatalError("Item has no view")
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        return false
    }
    
}

class SearchGroupCellView : NSTableCellView {
    
    @IBOutlet var operatorButton: NSPopUpButton!
    
    override var objectValue: Any? {
        didSet {
//            guard let searchGroup = objectValue as? FilterGroup else { return }
//
//            operatorButton.selectItem(at: filterGroup.op)
        }
    }
    
    @IBAction func operatorChanged(_ sender: NSPopUpButton!) {
//        guard var filterGroup = objectValue as? FilterGroup else { return }
//
//        print("Was: \(objectValue)")
//
//        filterGroup.op = sender.indexOfSelectedItem
//        print("Now: \(objectValue)")
    }
    
}
