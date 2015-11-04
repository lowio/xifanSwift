//
//  PriorityQueue.swift
//  X_Framework
//
//  Created by yeah on 15/10/28.
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
public struct BinaryHeapIndex
{
    //index
    public let index: Int;
}
extension BinaryHeapIndex: HeapIndexType
{
    public var branchSize: Int {return 2;}
    
    public init(_ index: Int) {
        self.index = index;
    }
    
    //trunk index of 'self'
    public func trunkIndex() -> BinaryHeapIndex {
        let i = (index - 1) >> 1;
        return BinaryHeapIndex(i);
    }
    
    //branch index of 'self'
    public func branchIndex() -> BinaryHeapIndex{
        let i = index << 1 + 1;
        return BinaryHeapIndex(i);
    }
}
public func ==(lsh: BinaryHeapIndex, rsh: BinaryHeapIndex) -> Bool{return lsh.index == rsh.index;}


//*********************************************************************************************************************
//*********************************************************************************************************************

//MARK: == BinaryPriorityQueue ==
public struct BinaryPriorityQueue<T> {
    
    //MARK: properties
    //============================= properties ===================================
    
    //sort according to isOrderedBefore
    private(set) public var isOrderedBefore: (T, T) -> Bool;
    
    //source
    private(set) var source: [T];
    
    //init
    public init(source: [T], isOrderedBefore: (T, T) -> Bool)
    {
        self.isOrderedBefore = isOrderedBefore;
        self.source = source;
        self.build();
    }
    
    //init
    public init(isOrderedBefore: (T, T) -> Bool)
    {
        self.init(source: [], isOrderedBefore: isOrderedBefore);
    }
}
extension BinaryPriorityQueue where T: Comparable
{
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
//MARK: extension CollectionType
extension BinaryPriorityQueue: CollectionType
{
    //start index
    public var startIndex: BinaryHeapIndex{return BinaryHeapIndex(0);}
    
    //end index
    public var endIndex: BinaryHeapIndex{return BinaryHeapIndex(self.source.endIndex);}
    
    //count
    public var count: Int{return self.source.count;}
    
    //'self' is empty
    public var isEmpty: Bool{return self.source.isEmpty}
    
    //subscript
    public subscript(position: BinaryHeapIndex) -> T{
        set{
            self.source[position.index] = newValue;
        }
        get{
            return self.source[position.index];
        }
    }
}
//MARK: extension HeapTranslatorType
extension BinaryPriorityQueue: HeapTranslatorType
{
//    //shift up element at index
//    public mutating func shiftUp(index: BinaryHeapIndex)
//    {
//        let shiftElement = self[index];
//        var shiftIndex = index;
//        let zero = self.startIndex.index;
//        
//        repeat{
//            let trunkIndex = shiftIndex.trunkIndex();
//            guard trunkIndex.index >= zero else{break;}
//            let trunkElement = self[trunkIndex];
//            
//            guard self.isOrderedBefore(shiftElement, trunkElement) else {break;}
//            self[shiftIndex] = self[trunkIndex];
//            self[trunkIndex] = shiftElement;
//            shiftIndex = trunkIndex;
//        }while true
//    }
//    
//    //shift down element at index
//    public mutating func shiftDown(index: BinaryHeapIndex)
//    {
//        let shiftElement = self[index];
//        var trunkIndex = index;
//        let end = self.endIndex.index;
//        
//        repeat{
//            var shiftIndex = trunkIndex;
//            var branchIndex = shiftIndex.branchIndex();
//            var branchCount = shiftIndex.branchSize;
//            
//            repeat{
//                guard branchCount > 0 && branchIndex.index < end else {break;}
//                if self.isOrderedBefore(self[branchIndex], self[shiftIndex]) {
//                    shiftIndex = branchIndex
//                }
//                branchCount--;
//                branchIndex = branchIndex.successor();
//            }while true
//            
//            guard shiftIndex != trunkIndex else{break;}
//            self[trunkIndex] = self[shiftIndex];
//            self[shiftIndex] = shiftElement;
//            trunkIndex = shiftIndex;
//        }while true;
//    }
}
extension BinaryPriorityQueue: PriorityQueueType
{
    //append element and resort
    mutating public func insert(element: T)
    {
        self.source.append(element);
        self.shiftUp(self.endIndex.predecessor());
    }
    
    //return(and remove) first element and resort
    mutating public func popBest() -> T?
    {
        if(self.isEmpty){return nil;}
        let first = self.source[0];
        let end = self.source.removeLast();
        guard !self.isEmpty else{return first;}
        self.source[0] = end;
        self.shiftDown(self.startIndex);
        return first;
    }
    
    //replace element at index
    public mutating func replaceElement(element: T, atIndex: BinaryHeapIndex)
    {
        self[atIndex] = element;
        
        //if element is better shiftup otherwise shiftdown
        let trunkIndex = atIndex.trunkIndex();
        guard self.isOrderedBefore(element, self[trunkIndex]) else{
            self.shiftUp(atIndex);
            return;
        }
        self.shiftDown(atIndex);
    }
}