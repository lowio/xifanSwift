//
//  PriorityQueue.swift
//  X_Framework
//
//  Created by yeah on 15/10/28.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//MARK: == HeapIndexTranslatorType ==
public protocol HeapTranslatorIndexType: BidirectionalIndexType
{
    //branch size, default = 2 <==> binary heap, 4 , 8 etc...
    var branchSize: Self.Distance{get}
    
    //index
    var index:Self.Distance{get set}
    
    //trunk index
    func trunkIndexOf() -> Self
    
    //branch index
    func branchIndexOf() -> Self
    
    //init
    init(_ index: Self.Distance)
}
extension HeapTranslatorIndexType
{
    //trunk index, implement yourself for better efficiency
    public func trunkIndexOf() -> Self
    {
        print("trunkIndexOf @warn :: trunk index, implement yourself for better efficiency")
        let i = (self.index - 1) / self.branchSize;
        return Self.init(i);
    }
    
    //branch index implement yourself for better efficiency
    public func branchIndexOf() -> Self
    {
        print("branchIndexOf @warn :: branch index implement yourself for better efficiency")
        let i = self.index * self.branchSize + 1;
        return Self.init(i);
    }
    
    public func successor() -> Self {
        return Self(self.index + 1);
    }
    
    public func predecessor() -> Self {
        return Self(self.index - 1);
    }
}
extension HeapTranslatorIndexType where Self: Hashable
{
    public var hashValue: Int{return self.index.hashValue;}
}
extension HeapTranslatorIndexType where Self: CustomDebugStringConvertible
{
    public var debugDescription: String{return "index : \(self.index), branchSize: \(self.branchSize)"};
}

//*********************************************************************************************************************
//*********************************************************************************************************************

//MARK: == HeapTranslatorType ==
public protocol HeapTranslatorType: CollectionType
{
    typealias Index: HeapTranslatorIndexType;
    
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
        //shift element
        let shiftElement = self[index];
        
        //shift index
        var shiftIndex = index;
        
        //shift up
        repeat{
            //trunk index
            let trunkIndex = shiftIndex.trunkIndexOf();
            
            //if trunkIndex is startIndex reuturn, otherwise shift next trunk
            guard trunkIndex.index > -1 else{break;}
            let trunkElement = self[trunkIndex];
            
            //compare: if shiftElement is better swap, otherwise return;
            guard self.isOrderedBefore(shiftElement, trunkElement) else {break;}
            self[shiftIndex] = self[trunkIndex];
            self[trunkIndex] = shiftElement;
            shiftIndex = trunkIndex;
        }while true
    }
    
    //shift down element at index
    public mutating func shiftDown(index: Self.Index)
    {
        //if index < endIndex continue otherwise return;
        guard index.index < self.count else {return;}
        
        //count
        let c = self.count;
        
        //shift element
        let shiftElement = self[index];
        
        //trunk index
        var trunkIndex = index;
        
        //branch size
        let bc = index.branchSize;
        repeat{
            //shift index
            var shiftIndex = trunkIndex;
            
            //first branch index
            var branchIndex = shiftIndex.branchIndexOf();
            guard branchIndex.index < c else{break;}
            
            //branch count
            var branchCount = bc;
            //repeat branch elements, make shiftIndex as best branchIndex
            repeat{
                if isOrderedBefore(self[branchIndex], self[shiftIndex]){
                    shiftIndex = branchIndex;
                }
                branchCount -= 1;
                branchIndex = branchIndex.successor();
            }while branchCount > 0 && branchIndex.index < c
            
            //if shiftIndex != trunkIndex swap otherwise return;
            guard shiftIndex != trunkIndex else{break;}
            self[trunkIndex] = self[shiftIndex];
            self[shiftIndex] = shiftElement;
            
            //shift index as trunk index
            trunkIndex = shiftIndex;
        }while true;
    }
    
    //priority sequence use isOrderedBefore function
    public mutating func build()
    {
        guard self.count > 1 else {return;}
        var _index = self.endIndex.predecessor().trunkIndexOf();
        repeat{
            self.shiftDown(_index);
            _index = _index.predecessor();
        }while _index.index > -1
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

//MARK: == BinaryHeapIndex ==
public struct BinaryHeapIndex: HeapTranslatorIndexType {
    
    //branch size
    public let branchSize = 2;
    
    //index
    public var index:Int;
    
    public init(_ index: Int)
    {
        self.index = index;
    }
    
    //trunk index
    public func trunkIndexOf() -> BinaryHeapIndex
    {
        let i = (self.index - 1) >> 1;
        return BinaryHeapIndex(i);
    }
    
    //branch index
    public func branchIndexOf() -> BinaryHeapIndex
    {
        let i = self.index << 1 + 1;
        return BinaryHeapIndex(i);
    }
    
    public func successor() -> BinaryHeapIndex {
        return BinaryHeapIndex(self.index + 1);
    }
    
    public func predecessor() -> BinaryHeapIndex {
        return BinaryHeapIndex(self.index - 1);
    }
}
public func ==(lsh: BinaryHeapIndex, rsh: BinaryHeapIndex) -> Bool
{
    return lsh.index == rsh.index;
}

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
    //shift up element at index
    public mutating func shiftUp(index: BinaryHeapIndex)
    {
        //shift element
        let shiftElement = self[index];
        
        //shift index
        var shiftIndex = index;
        
        //shift up
        repeat{
            //trunk index
            let trunkIndex = shiftIndex.trunkIndexOf();
            
            //if trunkIndex is startIndex reuturn, otherwise shift next trunk
            guard trunkIndex.index > -1 else{break;}
            let trunkElement = self[trunkIndex];
            
            //compare: if shiftElement is better swap, otherwise return;
            guard self.isOrderedBefore(shiftElement, trunkElement) else {break;}
            self[shiftIndex] = self[trunkIndex];
            self[trunkIndex] = shiftElement;
            shiftIndex = trunkIndex;
        }while true
    }
    
    //shift down element at index
    public mutating func shiftDown(index: BinaryHeapIndex)
    {
        //if index < endIndex continue otherwise return;
        guard index.index < self.count else {return;}
        
        //count
        let c = self.count;
        
        //shift element
        let shiftElement = self[index];
        
        //trunk index
        var trunkIndex = index;
        
        let bc = index.branchSize;
        
        repeat{
            //shift index
            var shiftIndex = trunkIndex;
            
            //first branch index
            var branchIndex = shiftIndex.branchIndexOf();
            guard branchIndex.index < c else{break;}
            
            //branch count
            var branchCount = bc;
            //repeat branch elements, make shiftIndex as best branchIndex
            repeat{
                if isOrderedBefore(self[branchIndex], self[shiftIndex]){
                    shiftIndex = branchIndex;
                }
                branchIndex = branchIndex.successor();
                branchCount -= 1;
            }while branchCount > 0 && branchIndex.index < c
            
            //if shiftIndex != trunkIndex swap otherwise return;
            guard shiftIndex != trunkIndex else{break;}
            self[trunkIndex] = self[shiftIndex];
            self[shiftIndex] = shiftElement;
            
            //shift index as trunk index
            trunkIndex = shiftIndex;
        }while true;
    }
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
        let trunkIndex = atIndex.trunkIndexOf();
        guard self.isOrderedBefore(element, self[trunkIndex]) else{
            self.shiftUp(atIndex);
            return;
        }
        self.shiftDown(atIndex);
    }
}