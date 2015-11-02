//
//  PriorityQueue.swift
//  X_Framework
//
//  Created by yeah on 15/10/28.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

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
extension HeapConvertible where Self.Source: CollectionType
{
    //indexof
    @warn_unused_result
    public func indexOf(@noescape predicate: (Self.Source.Generator.Element) throws -> Bool) rethrows -> Self.Source.Index?
    {
        return try self.source.indexOf(predicate);
    }
}
extension HeapConvertible where Self.Source: CollectionType, Self.Source.Generator.Element: Equatable
{
    //indexof
    @warn_unused_result
    public func indexOf(element: Self.Source.Generator.Element) -> Self.Source.Index?
    {
        return self.source.indexOf(element);
    }
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
extension BinaryPriorityArray: SequenceType
{
    public func generate() -> IndexingGenerator<[T]>
    {
        return self.source.generate();
    }
}