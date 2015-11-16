//
//  PriorityQueue.swift
//  X_Framework
//
//  Created by xifanGame on 15/10/28.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//MARK: == HeapIndexType ==
public protocol HeapIndexType: BidirectionalIndexType
{
    //branch count
    var branchSize: Int {get}
    
    //index
    var index: Int {get}
    
    //init
    init(_ index: Int)
    
    //trunk index of 'self'
    func trunkIndex() -> Self
    
    //branch index of 'self'
    func branchIndex() -> Self
}
extension HeapIndexType
{
    public func successor() -> Self {
        return Self(index + 1);
    }
    
    public func predecessor() -> Self {
        return Self(index - 1);
    }
}

//*********************************************************************************************************************
//*********************************************************************************************************************
//MARK: == HeapTranslatorType ==
public protocol HeapTranslatorType: CollectionType
{
    //trunk index generator type
    typealias Index: HeapIndexType;
    
    //MARK: properties
    //============================= properties ===================================
    
    //sort according to isOrderedBefore
    var isOrderedBefore: (Self.Generator.Element, Self.Generator.Element) -> Bool {get}
    
    //subscript
    subscript(position: Self.Index) -> Self.Generator.Element{get set}
    
    //MARK: functions
    //============================= functions ===================================
    
    //shift up element at index
    mutating func shiftUp(index: Self.Index)
    
    //shift down element at index
    mutating func shiftDown(index: Self.Index)
    
    //priority sequence use isOrderedBefore function
    mutating func build()
}
extension HeapTranslatorType
{
    //shift up element at index
    public mutating func shiftUp(index: Self.Index)
    {
        let shiftElement = self[index];
        var shiftIndex = index;
        let zero = self.startIndex.index;
        
        repeat{
            let trunkIndex = shiftIndex.trunkIndex();
            guard trunkIndex.index >= zero else{break;}
            let trunkElement = self[trunkIndex];
            
            guard self.isOrderedBefore(shiftElement, trunkElement) else {break;}
            self[shiftIndex] = self[trunkIndex];
            self[trunkIndex] = shiftElement;
            shiftIndex = trunkIndex;
        }while true
    }
    
    //shift down element at index
    public mutating func shiftDown(index: Self.Index)
    {
        let shiftElement = self[index];
        var trunkIndex = index;
        let end = self.endIndex.index;
        
        repeat{
            var shiftIndex = trunkIndex;
            var branchIndex = shiftIndex.branchIndex();
            var branchCount = shiftIndex.branchSize;
            
            repeat{
                guard branchCount > 0 && branchIndex.index < end else {break;}
                if self.isOrderedBefore(self[branchIndex], self[shiftIndex]) {
                    shiftIndex = branchIndex
                }
                branchCount--;
                branchIndex = branchIndex.successor();
            }while true
            
            guard shiftIndex != trunkIndex else{break;}
            self[trunkIndex] = self[shiftIndex];
            self[shiftIndex] = shiftElement;
            trunkIndex = shiftIndex;
        }while true;
    }
    
    //priority sequence use isOrderedBefore function
    public mutating func build()
    {
        guard self.count > 1 else {return;}
        let zero = self.startIndex.index;
        var _index = self.endIndex.predecessor().trunkIndex();
        repeat{
            self.shiftDown(_index);
            _index = _index.predecessor()
        }while _index.index >= zero
    }
}

//*********************************************************************************************************************
//*********************************************************************************************************************
public protocol PriorityQueueType: CollectionType
{
    //append element and resort
    mutating func insert(element: Self.Generator.Element)
    
    //return(and remove) first element and resort
    mutating func popBest() -> Self.Generator.Element?
    
    //replace element at index
    mutating func replaceElement(element: Self.Generator.Element, atIndex: Self.Index)
}

//*********************************************************************************************************************
//*********************************************************************************************************************
//MARK:======== Impl ========
//======================================== implement =================================================

//MARK: == PriorityQueue ==
public struct PriorityQueue<T>
{
    //base array
    private var base: [T];
    
    //sort according to isOrderedBefore
    private(set) var isOrderedBefore: (T, T) -> Bool;
    
    //init
    init(_ base: [T], _ isOrderedBefore: (T, T) -> Bool){
        self.base = base;
        self.isOrderedBefore = isOrderedBefore;
        self.build();
    }
    
    //init
    init(_ isOrderedBefore: (T, T) -> Bool){
        self.init([], isOrderedBefore);
    }
}
//MARK: extension internal
extension PriorityQueue{
    //trunk index of 'self'
    func trunkIndexOf(index: Int) -> Int {
        return (index - 1) >> 1;
    }
    
    //branch index of 'self'
    func branchIndexOf(index: Int) -> Int{
        return index << 1 + 1;
    }
    
    //shift up element at index
    mutating func shiftUp(index: Int) {
        let shiftElement = self.base[index];
        var shiftIndex = index;
        repeat{
            let trunkIndex = self.trunkIndexOf(shiftIndex);
            guard trunkIndex >= 0 else{break;}
            let trunkElement = self[trunkIndex];
            
            guard self.isOrderedBefore(shiftElement, trunkElement) else {break;}
            self.base[shiftIndex] = self.base[trunkIndex];
            self.base[trunkIndex] = shiftElement;
            shiftIndex = trunkIndex;
        }while true
    }
    
    //shift down element at index
    mutating func shiftDown(index: Int) {
        let shiftElement = self.base[index];
        var trunkIndex = index;
        let end = self.base.count;
        
        repeat{
            var shiftIndex = trunkIndex;
            var branchIndex = self.branchIndexOf(shiftIndex);
            var branchCount = 2;
            repeat{
                guard branchCount > 0 && branchIndex < end else {break;}
                if self.isOrderedBefore(self.base[branchIndex], self.base[shiftIndex]) {
                    shiftIndex = branchIndex
                }
                branchCount--;
                branchIndex++;
            }while true
            
            guard shiftIndex != trunkIndex else{break;}
            self.base[trunkIndex] = self.base[shiftIndex];
            self.base[shiftIndex] = shiftElement;
            trunkIndex = shiftIndex;
        }while true;
    }
    
    //priority sequence use isOrderedBefore function
    mutating func build() {
        guard self.base.count > 1 else {return;}
        var _index = self.trunkIndexOf(self.base.count - 1);
        repeat{
            self.shiftDown(_index);
            _index--;
        }while _index >= 0
    }
}
//MARK: extension PriorityQueueType
extension PriorityQueue: PriorityQueueType {
    //append element and resort
    mutating public func insert(element: T)
    {
        self.base.append(element);
        self.shiftUp(self.base.count - 1);
    }
    
    //return(and remove) first element and resort
    mutating public func popBest() -> T?
    {
        if(self.base.isEmpty){return nil;}
        let first = self.base[0];
        let end = self.base.removeLast();
        guard !self.base.isEmpty else{return first;}
        self.base[0] = end;
        self.shiftDown(0);
        return first;
    }
    
    //replace element at index
    public mutating func replaceElement(element: T, atIndex: Int)
    {
        self.base[atIndex] = element;
        let trunkIndex = self.trunkIndexOf(atIndex);
        guard self.isOrderedBefore(element, self.base[trunkIndex]) else{
            self.shiftUp(atIndex);
            return;
        }
        self.shiftDown(atIndex);
    }
}
//MARK: extension CollectionType
extension PriorityQueue: CollectionType {
    public var startIndex: Int{return self.base.startIndex;}
    public var endIndex: Int{return self.base.endIndex;}
    public subscript(position: Int) -> T{
        return self.base[position];
    }
}
extension PriorityQueue where T: Comparable
{
    //minimum heap
    public init(minimum source: [T] = [])
    {
        self.init(source){return $0 > $1;}
    }
    
    //maximum heap
    public init(maximum source: [T] = [])
    {
        self.init(source){return $0 < $1;}
    }
}

