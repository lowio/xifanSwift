//
//  PriorityQueue2.swift
//  X_Framework
//
//  Created by 173 on 16/1/7.
//  Copyright © 2016年 yeah. All rights reserved.
//

import Foundation


//MARK: == PriorityQueueIndexable ==
public protocol PriorityQueueIndexable: Indexable {
    
    ///branch size
    var branchSize: Index.Distance {get}
    
    ///return trunk index of index
    ///range: [startIndex, index)
    func trunkIndexOf(index: Index) -> Index?
    
    ///return branch index of index
    ///range: (index, endIndex)
    func branchIndexOf(index: Index) -> Index?
}
extension PriorityQueueIndexable where Self.Index == Int {
    ///return trunk index of index
    ///range: [startIndex, index)
    public func trunkIndexOf(index: Int) -> Int? {
        let i = (index - 1) / self.branchSize;
        return i < self.startIndex ? .None : i;
    }
    
    ///return branch index of index
    ///range: (index, endIndex)
    public func branchIndexOf(index: Int) -> Int? {
        let i = index * self.branchSize + 1;
        return i < self.endIndex ? i : .None;
    }
}


//MARK: == PriorityQueueSortable ==
public protocol PriorityQueueSortable2: PriorityQueueIndexable, MutableIndexable{
    
    ///is ordered before
    var isOrderedBefore: (_Element, _Element) -> Bool {get}
    
    ///shift up of index
    mutating func shiftUp(ofIndex: Index)
    
    ///shift down of index
    mutating func shiftDown(ofIndex: Index)
    
    ///replace element at index
    mutating func replace(element: _Element, at index: Index)
    
    ///build source
    mutating func build()
}
extension PriorityQueueSortable2 {
    
    ///shift up of index
    mutating public func shiftUp(ofIndex: Index) {
        let shiftElement = self[ofIndex];
        var shiftIndex = ofIndex;
        
        repeat{
            guard let trunkIndex = trunkIndexOf(shiftIndex) else {break;}
            let trunkElement = self[trunkIndex];
            
            guard isOrderedBefore(shiftElement, trunkElement) else {break;}
            self[shiftIndex] = self[trunkIndex];
            self[trunkIndex] = shiftElement;
            shiftIndex = trunkIndex;
        }while true
    }
    
    ///shift down of index
    mutating public func shiftDown(ofIndex: Index) {
        let shiftElement = self[ofIndex];
        var trunkIndex = ofIndex;
        let eIndex = self.endIndex;
        repeat{
            guard var branchIndex = branchIndexOf(trunkIndex) else {break;}
            var shiftIndex = trunkIndex;
            let bIndex = branchIndex;
            repeat{
                if isOrderedBefore(self[branchIndex], self[shiftIndex]) {
                    shiftIndex = branchIndex
                }
                branchIndex = branchIndex.successor();
                if branchIndex == eIndex || bIndex.distanceTo(branchIndex) >= branchSize {break;}
            }while true
            
            guard shiftIndex != trunkIndex else{break;}
            self[trunkIndex] = self[shiftIndex];
            self[shiftIndex] = shiftElement;
            trunkIndex = shiftIndex;
        }while true;
    }
    
    ///replace element at index
    mutating public func replace(element: _Element, at index: Index) {
        guard let tindex = trunkIndexOf(index)else{
            self.shiftDown(index);
            return;
        }
        let telement = self[tindex];
        self.isOrderedBefore(element, telement) ? shiftUp(index) : shiftDown(index);
    }
    
    ///build source
    mutating public func build() {
        let sindex = self.startIndex;
        let lastIndex = self.endIndex.advancedBy(-1);
        
        guard var index = self.trunkIndexOf(lastIndex) else {return;}
        repeat{
            self.shiftDown(index);
            guard index != sindex else {break;}
            index = index.advancedBy(-1);
        }while true
    }
}




///MARK: == PriorityQueueBinarySort ==
public struct PriorityQueueBinarySort2<Source: MutableIndexable where Source.Index == Int> {
    ///branch size, 2,4,8....
    public let branchSize = 2;
    
    ///source data
    public internal(set) var source: Source
    
    ///is ordered before
    public private(set) var isOrderedBefore: (Source._Element, Source._Element) -> Bool;
    
    ///init
    public init(source: Source, _ isOrderedBefore: (Source._Element, Source._Element) -> Bool) {
        self.isOrderedBefore = isOrderedBefore;
        self.source = source;
        self.build();
    }
}
extension PriorityQueueBinarySort2 {
    ///return trunk index of index
    ///if trunk index < source.startIndex return nil otherwise return trunk index
    public func trunkIndexOf(index: Int) -> Int? {
        let i = (index - 1) >> 1;
        return i < source.startIndex ? nil : i;
    }
    
    ///return branch index of index
    ///if branch index < source.endIndex return branch index otherwise return nil
    public func branchIndexOf(index: Int) -> Int? {
        let i = index << 1 + 1;
        return i < source.endIndex ? i : nil;
    }
}
extension PriorityQueueBinarySort2 : PriorityQueueSortable2 {
    public var startIndex: Source.Index{return source.startIndex;}
    public var endIndex: Source.Index{return source.endIndex;}
    public subscript(position: Source.Index) -> Source._Element {
        set{
            self.source[position] = newValue;
        }
        get{
            return self.source[position];
        }
    }
}


//MARK: == PriorityArray ==
public struct PriorityArray2<T>
{
    ///delegate
    public private(set) var delegate: PriorityQueueBinarySort2<Array<T>>;
    
    //init
    public init(source: [T], _ isOrderedBefore: (T, T) -> Bool){
        self.delegate = PriorityQueueBinarySort2(source: source, isOrderedBefore);
    }
    
    //init
    public init(_ isOrderedBefore: (T, T) -> Bool){
        self.init(source: [], isOrderedBefore);
    }
}
//MARK: extension PriorityQueueType
extension PriorityArray2: PriorityQueueType {
    //append element and resort
    mutating public func insert(element: T) {
        delegate.source.append(element);
        delegate.shiftUp(delegate.source.count - 1);
    }
    
    //return(and remove) first element and resort
    mutating public func popBest() -> T? {
        if(delegate.source.isEmpty){return nil;}
        let first = delegate.source[0];
        let end = delegate.source.removeLast();
        guard !delegate.source.isEmpty else{return first;}
        delegate.source[0] = end;
        delegate.shiftDown(0);
        return first;
    }
    
    //replace element at index
    mutating public func replace(element: T, at index: Int) {
        delegate.replace(element, at: index);
    }
}
//MARK: extension CollectionType
extension PriorityArray2: CollectionType {
    public var startIndex: Int{return delegate.source.startIndex;}
    public var endIndex: Int{return delegate.source.endIndex;}
    public subscript(position: Int) -> T{
        return self.delegate.source[position];
    }
}
extension PriorityArray2 where T: Comparable {
    //minimum heap
    public init(minimum source: [T] = [])
    {
        self.init(source: source){return $0 < $1;}
    }
    
    //maximum heap
    public init(maximum source: [T] = [])
    {
        self.init(source: source){return $0 > $1;}
    }
}


///MARK: extension PriorityQueueBinaryDelegate, recode shiftUp shiftDown replace and build
//extension PriorityQueueBinarySort2{
//    ///shift up of index
//    mutating public func shiftUp(ofIndex: Source.Index) {
//        let shiftElement = self[ofIndex];
//        var shiftIndex = ofIndex;
//        
//        repeat{
//            guard let trunkIndex = trunkIndexOf(shiftIndex) else {break;}
//            let trunkElement = self[trunkIndex];
//            
//            guard isOrderedBefore(shiftElement, trunkElement) else {break;}
//            self[shiftIndex] = self[trunkIndex];
//            self[trunkIndex] = shiftElement;
//            shiftIndex = trunkIndex;
//        }while true
//    }
//    
//    ///shift down of index
//    mutating public func shiftDown(ofIndex: Source.Index) {
//        let shiftElement = self[ofIndex];
//        var trunkIndex = ofIndex;
//        let eIndex = self.endIndex;
//        repeat{
//            guard var branchIndex = branchIndexOf(trunkIndex) else {break;}
//            var shiftIndex = trunkIndex;
//            let bIndex = branchIndex;
//            repeat{
//                if isOrderedBefore(self[branchIndex], self[shiftIndex]) {
//                    shiftIndex = branchIndex
//                }
//                branchIndex = branchIndex.successor();
//                if branchIndex == eIndex || branchIndex - bIndex >= branchSize {break;}
//            }while true
//            
//            guard shiftIndex != trunkIndex else{break;}
//            self[trunkIndex] = self[shiftIndex];
//            self[shiftIndex] = shiftElement;
//            trunkIndex = shiftIndex;
//        }while true;
//    }
//    
//    ///replace element at index
//    mutating public func replace(element: Source._Element, at index: Source.Index) {
//        guard let tindex = trunkIndexOf(index)else{
//            self.shiftDown(index);
//            return;
//        }
//        let telement = self[tindex];
//        self.isOrderedBefore(element, telement) ? shiftUp(index) : shiftDown(index);
//    }
//    
//    ///build source
//    mutating public func build() {
//        let sindex = self.startIndex;
//        let lastIndex = self.endIndex.advancedBy(-1);
//        
//        guard var index = self.trunkIndexOf(lastIndex) else {return;}
//        repeat{
//            self.shiftDown(index);
//            guard index != sindex else {break;}
//            index = index.advancedBy(-1);
//        }while true
//    }
//}

