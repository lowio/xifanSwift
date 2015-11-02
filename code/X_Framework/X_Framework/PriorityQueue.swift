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
        return Self.init(self.index + 1);
    }
    
    public func predecessor() -> Self {
        return Self.init(self.index - 1);
    }
}

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
        guard index.index < self.endIndex.index else {return;}
        
        //endindex
        let endi = self.endIndex.index;
        
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
            guard branchIndex.index < endi else{break;}
            
            //branch count
            var branchCount = bc;
            //repeat branch elements, make shiftIndex as best branchIndex
            repeat{
                if isOrderedBefore(self[branchIndex], self[shiftIndex]){
                    shiftIndex = branchIndex;
                }
                branchIndex = branchIndex.successor();
                branchCount -= 1;
            }while branchIndex.index < endi && branchCount > 0
            
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
        guard self.endIndex.index - self.startIndex.index > 1 else {return;}
        var _index = self.endIndex.predecessor().trunkIndexOf();
        repeat{
            self.shiftDown(_index);
            _index = _index.predecessor();
        }while _index.index > -1
    }
}


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
}
public func ==(lsh: BinaryHeapIndex, rsh: BinaryHeapIndex) -> Bool
{
    return lsh.index == rsh.index;
}

public struct BinaryHeapArray<T> {
    
    //MARK: properties
    //============================= properties ===================================
    
    //sort according to isOrderedBefore
    private(set) public var isOrderedBefore: (T, T) -> Bool;
    
    private(set) var source: [T];
    
    //init
    public init(source: [T], isOrderedBefore: (T, T) -> Bool)
    {
        self.isOrderedBefore = isOrderedBefore;
        self.source = source;
        self.build();
    }
    
}
extension BinaryHeapArray: HeapTranslatorType
{
    public var startIndex: BinaryHeapIndex{return BinaryHeapIndex(0);}
    public var endIndex: BinaryHeapIndex{return BinaryHeapIndex(self.source.endIndex);}
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
extension BinaryHeapArray
{
    //MARK: properties
    //============================= properties ===================================
    //count
    public var count: Int{return self.source.count;}
    
    //'self' is empty
    public var isEmpty: Bool{return self.source.isEmpty}
    
    //MARK: functions
    //============================= functions ===================================
    
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
        guard index.index < self.endIndex.index else {return;}
        
        //endindex
        let endi = self.endIndex.index;
        
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
            guard branchIndex.index < endi else{break;}
            
            //branch count
            var branchCount = bc;
            //repeat branch elements, make shiftIndex as best branchIndex
            repeat{
                if isOrderedBefore(self[branchIndex], self[shiftIndex]){
                    shiftIndex = branchIndex;
                }
                branchIndex = branchIndex.successor();
                branchCount -= 1;
            }while branchIndex.index < endi && branchCount > 0
            
            //if shiftIndex != trunkIndex swap otherwise return;
            guard shiftIndex != trunkIndex else{break;}
            self[trunkIndex] = self[shiftIndex];
            self[shiftIndex] = shiftElement;
            
            //shift index as trunk index
            trunkIndex = shiftIndex;
        }while true;
    }

}


//===================
//===================
//===================
//===================
//===================
//===================
//===================
//===================
//===================
//===================



//MARK: == HeapConvertible ==
public protocol HeapConvertible
{
    //source
    typealias Source: MutableIndexable;
    
    //element type
    typealias Element = Self.Source._Element;
    
    //index type
    typealias Index: ForwardIndexType = Self.Source.Index;
    
    //MARK: properties
    //============================= properties ===================================
    
    //branch size, default = 2 <==> binary heap, 4 , 8 etc...
    var branchSize: Self.Index.Distance{get}
    
    //source
    var source: Self.Source{get set}
    
    //sort according to isOrderedBefore
    var isOrderedBefore: (Self.Element, Self.Element) -> Bool {get}
    
    //MARK: functions
    //============================= functions ===================================
    //shift up element at index
    mutating func shiftUp(index: Self.Index)
    
    //shift down element at index
    mutating func shiftDown(index: Self.Index)
    
    //priority sequence use isOrderedBefore function
    mutating func build()
    
    //trunk index
    func trunkIndexOf(branchIndex: Self.Index) -> Self.Index
    
    //branch index
    func branchIndexOf(trunkIndex: Self.Index) -> Self.Index
}
//MARK: extension public
extension HeapConvertible where Self.Index == Self.Source.Index, Self.Element == Self.Source._Element
{
    //shift up element at index
    public mutating func shiftUp(index: Self.Index)
    {
        //shift element
        let shiftElement = self.source[index];

        //shift index
        var shiftIndex = index;
        
        //shift up
        repeat{
            //trunk index
            let trunkIndex = self.trunkIndexOf(shiftIndex);
            
            //if trunkIndex is startIndex reuturn, otherwise shift next trunk
            guard self.source.startIndex.distanceTo(trunkIndex) > -1 else{break;}
            let trunkElement = self.source[trunkIndex];
            
            //compare: if shiftElement is better swap, otherwise return;
            guard self.isOrderedBefore(shiftElement, trunkElement) else {break;}
            self.source[shiftIndex] = self.source[trunkIndex];
            self.source[trunkIndex] = shiftElement;
            shiftIndex = trunkIndex;
        }while true
    }
    
    //shift down element at index
    public mutating func shiftDown(index: Self.Index)
    {
        //if index < endIndex continue otherwise return;
        guard index.distanceTo(self.source.endIndex) > 0 else {return;}
        
        //endindex
        let endi = self.source.endIndex;
        
        //shift element
        let shiftElement = self.source[index];
        
        //trunk index
        var trunkIndex = index;
        
        repeat{
            //shift index
            var shiftIndex = trunkIndex;
            
            //first branch index
            var branchIndex = self.branchIndexOf(shiftIndex);
            guard branchIndex.distanceTo(endi) > 0 else{break;}
            
            //branch count
            var branchCount = self.branchSize;
            //repeat branch elements, make shiftIndex as best branchIndex
            repeat{
                if isOrderedBefore(self.source[branchIndex], self.source[shiftIndex]){
                    shiftIndex = branchIndex;
                }
                branchIndex = branchIndex.advancedBy(1);
                branchCount -= 1;
            }while branchIndex.distanceTo(endi) > 0 && branchCount > 0
            
            //if shiftIndex != trunkIndex swap otherwise return;
            guard shiftIndex != trunkIndex else{break;}
            self.source[trunkIndex] = self.source[shiftIndex];
            self.source[shiftIndex] = shiftElement;
            
            //shift index as trunk index
            trunkIndex = shiftIndex;
        }while true;
    }
    
    //priority sequence use isOrderedBefore function
    public mutating func build()
    {
        guard self.source.startIndex.distanceTo(self.source.endIndex) > 0 else {return;}
        var _index = self.trunkIndexOf(self.source.endIndex.advancedBy(-1))
        repeat{
            self.shiftDown(_index);
            _index = _index.advancedBy(-1);
        }while self.source.startIndex.distanceTo(_index) > -1
    }
    
    //trunk index, implement yourself for better efficiency
    public func trunkIndexOf(branchIndex: Self.Index) -> Self.Index
    {
        print("trunkIndexOf @warn :: trunk index, implement yourself for better efficiency")
        let distance = self.source.startIndex.distanceTo(branchIndex);
        let trunkDistance = (distance - 1) / self.branchSize;
        return self.source.startIndex.advancedBy(trunkDistance);
    }
    
    //branch index implement yourself for better efficiency
    public func branchIndexOf(trunkIndex: Self.Index) -> Self.Index
    {
        print("branchIndexOf @warn :: branch index implement yourself for better efficiency")
        let distance = self.source.startIndex.distanceTo(trunkIndex);
        let branchDistance = distance * self.branchSize + 1;
        return self.source.startIndex.advancedBy(branchDistance);
    }
}

//*********************************************************************************************************************
//*********************************************************************************************************************

//MARK: == PriorityQueueType ==
public protocol PriorityQueueType: HeapConvertible
{
    //MARK: properties
    //============================= properties ===================================
    //count
    var count: Self.Index.Distance{get}
    
    //'self' is empty
    var isEmpty: Bool{get}
    
    //MARK: functions
    //============================= functions ===================================
    //append element and resort
    mutating func insert(element: Self.Element)
    
    //return(and remove) first element and resort
    mutating func popBest() -> Self.Element?
    
    //replace element at index, shift element to heap position
    mutating func replaceElement(element: Self.Element, atIndex: Self.Index)
}

//*********************************************************************************************************************
//*********************************************************************************************************************

//======================================== implement =================================================

//MARK: == BinaryPriorityArray ==
public struct BinaryPriorityArray<T>
{
    //branch size, default = 2 <==> binary heap, 4 , 8 etc...
    public let branchSize: Int = 2;
    
    //sort according to isOrderedBefore
    private (set) public var isOrderedBefore: (T, T) -> Bool;
    
    //source
    public var source: [T];
    
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
extension BinaryPriorityArray where T: Comparable
{
    //minimum heap
    public init(minimum source: [T])
    {
        self.init(source: source){return $0 > $1;}
    }
    
    //maximum heap
    public init(maximum source: [T])
    {
        self.init(source: source){return $0 < $1;}
    }
}
extension BinaryPriorityArray: CollectionType
{
    public var startIndex: Int{return 0;}
    public var endIndex: Int{return self.source.endIndex;}
    public subscript(position: Int) -> T{
        return self.source[position];
    }
}
//MARK: extension PriorityQueueType
extension BinaryPriorityArray: PriorityQueueType
{
    //MARK: properties
    //============================= properties ===================================
    //count
    public var count: Int{return self.source.count;}
    
    //'self' is empty
    public var isEmpty: Bool{return self.source.isEmpty}
    
    //MARK: functions
    //============================= functions ===================================
    
    //append element and resort
    mutating public func insert(element: T)
    {
        self.source.append(element);
        self.shiftUp(self.count - 1);
    }
    
    //return(and remove) first element and resort
    mutating public func popBest() -> T?
    {
        if(self.isEmpty){return nil;}
        let first = self.source[0];
        let end = self.source.removeLast();
        guard !self.isEmpty else{return first;}
        self.source[0] = end;
        self.shiftDown(0);
        return first;
    }
}
//MARK: extension  HeapConvertible
extension BinaryPriorityArray: HeapConvertible
{
    //trunk index
    public func trunkIndexOf(branchIndex: Int) -> Int
    {
        return (branchIndex - 1) >> 1;
    }
    
    //branch index
    public func branchIndexOf(trunkIndex: Int) -> Int
    {
        return trunkIndex << 1 + 1;
    }
    
    //shift up element at index
    public mutating func shiftUp(index: Int)
    {
        //shift element
        let shiftElement = self.source[index];
        
        //shift index
        var shiftIndex = index;
        
        //shift up
        repeat{
            //trunk index
            let trunkIndex = self.trunkIndexOf(shiftIndex);
            
            //if trunkIndex is startIndex reuturn, otherwise shift next trunk
            guard trunkIndex > -1 else{break;}
            let trunkElement = self.source[trunkIndex];
            
            //compare: if shiftElement is better swap, otherwise return;
            guard self.isOrderedBefore(shiftElement, trunkElement) else {break;}
            self.source[shiftIndex] = self.source[trunkIndex];
            self.source[trunkIndex] = shiftElement;
            shiftIndex = trunkIndex;
        }while true
    }
    
    //shift down element at index
    public mutating func shiftDown(index: Int)
    {
        //if index < endIndex continue otherwise return;
        guard index < self.count else {return;}
        
        //endindex
        let endi = self.source.count;
        
        //shift element
        let shiftElement = self.source[index];
        
        //trunk index
        var trunkIndex = index;
        
        repeat{
            //shift index
            var shiftIndex = trunkIndex;
            
            //first branch index
            var branchIndex = self.branchIndexOf(shiftIndex);
            guard branchIndex < endi else{break;}
            
            //branch count
            var branchCount = self.branchSize;
            //repeat branch elements, make shiftIndex as best branchIndex
            repeat{
                if isOrderedBefore(self.source[branchIndex], self.source[shiftIndex]){
                    shiftIndex = branchIndex;
                }
                branchIndex++;
                branchCount--;
            }while branchIndex < endi && branchCount > 0
            
            //if shiftIndex != trunkIndex swap otherwise return;
            guard shiftIndex != trunkIndex else{break;}
            self.source[trunkIndex] = self.source[shiftIndex];
            self.source[shiftIndex] = shiftElement;
            
            //shift index as trunk index
            trunkIndex = shiftIndex;
        }while true;
    }
    
    //priority sequence use isOrderedBefore function
    public mutating func build()
    {
        guard self.count > 1 else {return;}
        var _index = self.trunkIndexOf(self.source.count - 1)
        repeat{
            self.shiftDown(_index);
            _index--;
        }while _index > -1
    }
    
    //replace element at index
    public mutating func replaceElement(element: T, atIndex: Int)
    {
        self.source[atIndex] = element;
        
        //if element is better shiftup otherwise shiftdown
        let trunkIndex = self.trunkIndexOf(atIndex);
        guard self.isOrderedBefore(element, self.source[trunkIndex]) else{
            self.shiftUp(atIndex);
            return;
        }
        self.shiftDown(atIndex);
    }
}