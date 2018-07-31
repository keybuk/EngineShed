//
//  IndexSortable.swift
//  EngineShed
//
//  Created by Scott James Remnant on 7/26/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

/// Type that can be sorted using an index property.
///
/// To sort sets of objects without using an ordered set, or array, the type can conform to this
/// protocol by adding an integer `index` property, and using the extensions on `Sequence` and
/// `Array` to maintain it.
///
///     let elements = elementSet.sorted()
///     newElement.index = elements.indexForInserting(at: ...)
///
public protocol IndexSortable : class {

    associatedtype Index : SignedInteger
    var index: Index { get set }

}

extension Sequence where Element : IndexSortable {

    /// Returns the elements of the sequence, sorted using the elements `index`.
    public func sorted() -> [Element] {
        return sorted(by: { $0.index < $1.index })
    }

}

extension Array where Element : IndexSortable {

    /// Returns a new element index for appending.
    ///
    /// The returned index is guaranteed to be greater than any element index already in the array.
    public func indexForAppending() -> Element.Index {
        return (last?.index ?? 0) + 64
    }

    /// Returns a new element index for inserting.
    ///
    /// The returned index is guaranteed to be greater than any element index preceeding it, and
    /// less than any element index after it.
    ///
    /// If necessary, indexes of elements after the insertion point may be modified to make space.
    public func indexForInserting(at index: Index) -> Element.Index {
        guard index < endIndex else { return indexForAppending() }

        let upperIndex = self[index].index
        let lowerIndex = index > startIndex ? self[index - 1].index : 0

        var newIndex = 1 + lowerIndex + (upperIndex - lowerIndex - 1) / 2
        if newIndex == upperIndex {
            // When there isn't space for a new index, we have to renumber the array from this
            // point. Since we're modifying things, go the whole hog and just renumber everything
            // to make plenty of new space.
            newIndex = lowerIndex + 64

            var nextIndex = newIndex + 64
            for element in self[index...] {
                element.index = nextIndex
                nextIndex += 64
            }
        }

        return newIndex
    }

}
