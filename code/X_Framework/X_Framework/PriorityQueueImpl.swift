//
//  PriorityQueueImpl.swift
//  X_Framework
//
//  Created by 173 on 15/10/27.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation


//MARK: priority queue use array collection
public struct PriorityArray<T>
{
    //source
    public private(set) var source:SourceType;
    
    //is ordered before
    private var _isOrderedBefore:(T, T) -> Bool;
}

//MARK: extension BinaryHeapConvertible
extension PriorityArray: BinaryHeapConvertible
{
    //mutable collection type
    public typealias SourceType = Array<T>;
    
    //init with resource, compare
    public init(source:[T], isOrderedBefore:(T, T) -> Bool)
    {
        self._isOrderedBefore = isOrderedBefore;
        guard let temp = PriorityArray.build(source, isOrderedBefore: self._isOrderedBefore) else {
            self.source = source;
            return;
        }
        self.source = temp;
    }
}
//MARK: extension CollectionType
extension PriorityArray: CollectionType{}
//MARK: extension binary heap collection type
extension PriorityArray: BinaryHeapCollectionType
{
    //init
    public init(isOrderedBefore:(T, T) -> Bool)
    {
        self.init(source: [], isOrderedBefore:isOrderedBefore);
    }
    
    //append element and resort
    public mutating func append(newElement: T)
    {
        self.source.append(newElement);
        guard let temp = PriorityArray.shiftUp(self.source, atIndex: self.count - 1, isOrderedBefore: self._isOrderedBefore) else {return;}
        self.source = temp;
    }
    
    //return(and remove) first element and resort
    public mutating func popFirst() -> T?
    {
        if(isEmpty){return nil;}
        let first = self.source[0];
        let end = self.source.removeLast();
        guard !self.isEmpty else{return first;}
        self.source[0] = end;
        guard let temp = PriorityArray.shiftDown(self.source, atIndex: 0, isOrderedBefore: self._isOrderedBefore) else {return first;}
        self.source = temp;
        return first;
    }
    
    //update element and resort
    public mutating func updateElement(element: T, atIndex: Int)
    {
        guard atIndex >= 0 && atIndex < self.count else{return;}
        guard let temp = PriorityArray.updateElement(self.source, element: element, atIndex: atIndex, isOrderedBefore: self._isOrderedBefore) else {return;}
        self.source = temp;
    }
}

//MARK: extension public
public extension PriorityArray where T: Comparable
{
    //    init(max source:[T])
    //    {
    //        self.init(source: source){$0 < $1}
    //    }
    //
    //    init(min source:[T])
    //    {
    //        self.init(source: source){$0 > $1}
    //    }
}