//
//  PriorityQueue.swift
//  X_Framework
//
//  Created by xifanGame on 15/10/28.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//MARK: == PriorityQueueDelegateType ==
public protocol PriorityQueueDelegateType{
    
    ///source type
    typealias Source: MutableIndexable;
    
    ///branch size, 2,4,8....
    var size: Source.Index.Distance{get}
    
    ///source data
    var source: Source{get set}
    
    ///is ordered before
    var isOrderedBefore: (Source._Element, Source._Element) -> Bool{get}
    
    ///return trunk index of index
    ///if trunk index < source.startIndex return nil otherwise return trunk index
    func trunkIndexOf(index: Source.Index) -> Source.Index?
    
    ///return branch index of index
    ///if branch index < source.endIndex return branch index otherwise return nil
    func branchIndexOf(index: Source.Index) -> Source.Index?
    
    ///shift up of index
    mutating func shiftUp(ofIndex: Source.Index)
    
    ///shift down of index
    mutating func shiftDown(ofIndex: Source.Index)
    
    ///replace element at index
    mutating func replace(element: Source._Element, at index: Source.Index)
    
    ///build source
    mutating func build(source: Source)
}
extension PriorityQueueDelegateType {
    
    ///shift up of index
    mutating public func shiftUp(ofIndex: Source.Index) {
        let shiftElement = source[ofIndex];
        var shiftIndex = ofIndex;
        
        repeat{
            guard let trunkIndex = trunkIndexOf(shiftIndex) else {break;}
            let trunkElement = source[trunkIndex];
            
            guard isOrderedBefore(shiftElement, trunkElement) else {break;}
            source[shiftIndex] = source[trunkIndex];
            source[trunkIndex] = shiftElement;
            shiftIndex = trunkIndex;
        }while true
    }
    
    ///shift down of index
    mutating public func shiftDown(ofIndex: Source.Index) {
        let shiftElement = source[ofIndex];
        var trunkIndex = ofIndex;
        let eIndex = source.endIndex;
        repeat{
            guard var branchIndex = branchIndexOf(trunkIndex) else {break;}
            var shiftIndex = trunkIndex;
            let bIndex = branchIndex;
            repeat{
                if isOrderedBefore(source[branchIndex], source[shiftIndex]) {
                    shiftIndex = branchIndex
                }
                branchIndex = branchIndex.successor();
                if branchIndex == eIndex || bIndex.distanceTo(branchIndex) >= size {break;}
            }while true
            
            guard shiftIndex != trunkIndex else{break;}
            source[trunkIndex] = source[shiftIndex];
            source[shiftIndex] = shiftElement;
            trunkIndex = shiftIndex;
        }while true;
    }
    
    ///replace element at index
    mutating public func replace(element: Source._Element, at index: Source.Index) {
        guard let tindex = trunkIndexOf(index)else{
            self.shiftDown(index);
            return;
        }
        let telement = source[tindex];
        self.isOrderedBefore(element, telement) ? shiftUp(index) : shiftDown(index);
    }
    
    ///build source
    mutating public func build(s: Source) {
        self.source = s;
        let sindex = self.source.startIndex;
        let lastIndex = self.source.endIndex.advancedBy(-1);
        
        guard var index = self.trunkIndexOf(lastIndex) else {return;}
        repeat{
            self.shiftDown(index);
            guard index != sindex else {break;}
            index = index.advancedBy(-1);
        }while true
    }
}
extension PriorityQueueDelegateType where Self.Source.Index == Int{
    ///return trunk index of index
    ///if trunk index < source.startIndex return nil otherwise return trunk index
    public func trunkIndexOf(index: Int) -> Int? {
        let i = (index - 1) / self.size;
        return i < source.startIndex ? nil : i;
    }
    
    ///return branch index of index
    ///if branch index < source.endIndex return branch index otherwise return nil
    public func branchIndexOf(index: Int) -> Int? {
        let i = index * self.size + 1;
        return i < source.endIndex ? i : nil;
    }
}

//MARK: == PriorityQueueType ==
public protocol PriorityQueueType: CollectionType
{
    //append element and resort
    mutating func insert(element: Self.Generator.Element)
    
    //return(and remove) first element and resort
    mutating func popBest() -> Self.Generator.Element?
    
    //replace element at index
    mutating func replace(element: Self.Generator.Element, at index: Self.Index)
}

///MARK: == PriorityQueueBinaryDelegate ==
public struct PriorityQueueBinaryDelegate<Source: MutableIndexable where Source.Index == Int> {
    ///branch size, 2,4,8....
    public let size = 2;
    
    ///source data
    public var source: Source
    
    ///is ordered before
    public private(set) var isOrderedBefore: (Source._Element, Source._Element) -> Bool;
    
    ///init
    public init(source: Source, _ isOrderedBefore: (Source._Element, Source._Element) -> Bool) {
        self.isOrderedBefore = isOrderedBefore;
        self.source = source;
        self.build(source);
    }
}
extension PriorityQueueBinaryDelegate {
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
extension PriorityQueueBinaryDelegate : PriorityQueueDelegateType {}


//MARK: == PriorityArray ==
public struct PriorityArray<T>
{
    ///delegate
    public private(set) var delegate: PriorityQueueBinaryDelegate<Array<T>>;
    
    //init
    public init(source: [T], _ isOrderedBefore: (T, T) -> Bool){
        self.delegate = PriorityQueueBinaryDelegate(source: source, isOrderedBefore);
    }
    
    //init
    public init(_ isOrderedBefore: (T, T) -> Bool){
        self.init(source: [], isOrderedBefore);
    }
}
//MARK: extension PriorityQueueType
extension PriorityArray: PriorityQueueType {
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
extension PriorityArray: CollectionType {
    public var startIndex: Int{return delegate.source.startIndex;}
    public var endIndex: Int{return delegate.source.endIndex;}
    public subscript(position: Int) -> T{
        return self.delegate.source[position];
    }
}
extension PriorityArray where T: Comparable {
    //minimum heap
    public init(minimum source: [T] = [])
    {
        self.init(source: source){return $0 > $1;}
    }
    
    //maximum heap
    public init(maximum source: [T] = [])
    {
        self.init(source: source){return $0 < $1;}
    }
}


///MARK: extension PriorityQueueBinaryDelegate, recode shiftUp shiftDown replace and build
extension PriorityQueueBinaryDelegate{
    ///shift up of index
    mutating public func shiftUp(ofIndex: Source.Index) {
        let shiftElement = source[ofIndex];
        var shiftIndex = ofIndex;
        
        repeat{
            guard let trunkIndex = trunkIndexOf(shiftIndex) else {break;}
            let trunkElement = source[trunkIndex];
            
            guard isOrderedBefore(shiftElement, trunkElement) else {break;}
            source[shiftIndex] = source[trunkIndex];
            source[trunkIndex] = shiftElement;
            shiftIndex = trunkIndex;
        }while true
    }
    
    ///shift down of index
    mutating public func shiftDown(ofIndex: Source.Index) {
        let shiftElement = source[ofIndex];
        var trunkIndex = ofIndex;
        let eIndex = source.endIndex;
        repeat{
            guard var branchIndex = branchIndexOf(trunkIndex) else {break;}
            var shiftIndex = trunkIndex;
            let bIndex = branchIndex;
            repeat{
                if isOrderedBefore(source[branchIndex], source[shiftIndex]) {
                    shiftIndex = branchIndex
                }
                branchIndex = branchIndex.successor();
                if branchIndex == eIndex || branchIndex - bIndex >= size {break;}
            }while true
            
            guard shiftIndex != trunkIndex else{break;}
            source[trunkIndex] = source[shiftIndex];
            source[shiftIndex] = shiftElement;
            trunkIndex = shiftIndex;
        }while true;
    }
    
    ///replace element at index
    mutating public func replace(element: Source._Element, at index: Source.Index) {
        guard let tindex = trunkIndexOf(index)else{
            self.shiftDown(index);
            return;
        }
        let telement = source[tindex];
        self.isOrderedBefore(element, telement) ? shiftUp(index) : shiftDown(index);
    }
    
    ///build source
    mutating public func build(s: Source) {
        self.source = s;
        let sindex = self.source.startIndex;
        let lastIndex = self.source.endIndex.advancedBy(-1);
        
        guard var index = self.trunkIndexOf(lastIndex) else {return;}
        repeat{
            self.shiftDown(index);
            guard index != sindex else {break;}
            index = index.advancedBy(-1);
        }while true
    }
}











