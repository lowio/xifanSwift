//
//  PrioritySequenceImpl.swift
//  X_Framework
//
//  Created by 叶贤辉 on 15/10/29.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation




//MARK: HeapConvertor
public struct HeapConvertor<T>
{
    //Source type
    public typealias Source = Array<T>;
    
    //source
    public var source: Source;
    
    //branch maximum
    public let branchSize: Source.Index.Distance = 2;
    
    //sort according to isOrderedBefore
    private (set) public var isOrderedBefore: (Source._Element, Source._Element)->Bool;
    
    //init
    init(source: Source, isOrderedBefore: (Source._Element, Source._Element)->Bool)
    {
        self.source = source;
        self.isOrderedBefore = isOrderedBefore;
        self.build();
    }
}

//extension SequenceType
extension HeapConvertor: SequenceType
{
    public func generate() -> Source.Generator {
        return self.source.generate();
    }
}

//extension PriorityBinaryTree
extension HeapConvertor: MutableIndexable
{
    public var startIndex: Source.Index {return self.source.startIndex;}
    
    public var endIndex: Source.Index {return self.source.endIndex;}
    
    public subscript (position: Source.Index) -> Source._Element {
        set{
            self.source[position] = newValue;
        }
        get{
            return self.source[position];
        }
    }
}

//extension PriorityTreeConvertible
extension HeapConvertor: HeapConvertorType
{
    //trunk index
    public func trunkIndexOf(branchIndex: Source.Index) -> Source.Index
    {
//        let distance = self.startIndex.distanceTo(branchIndex);
//        let trunkDistance = (distance - 1) >> 1;
//        return self.startIndex.advancedBy(trunkDistance);
        return (branchIndex - 1) >> 1;
    }
    
    //branch index
    public func branchIndexOf(trunkIndex: Source.Index) -> Source.Index
    {
//        let distance = self.startIndex.distanceTo(trunkIndex);
//        let branchDistance = distance << 1 + 1;
//        return self.startIndex.advancedBy(branchDistance);
        return (trunkIndex << 1) + 1;
    }
}
//extension HeapConvertor: PrioritySequenceType
//{
//    //count
//    public var count: Source.Index.Distance{return self.source.count;}
//    
//    //'self' is empty
//    public var isEmpty: Bool{return self.source.isEmpty;}
//    
//    //append element and resort
//    public mutating func insert(element: Source.Generator.Element)
//    {
//        self.source.append(element);
//        self.shiftUp(self.count - 1);
//    }
//    
//    //return(and remove) first element and resort
//    public mutating func popBest() -> Source.Generator.Element?
//    {
//        if(self.isEmpty){return nil;}
//        let first = self.source[0];
//        let end = self.source.removeLast();
//        guard !self.isEmpty else{return first;}
//        self.source[0] = end;
//        self.shiftDown(0);
//        return first;
//    }
//    
//    //update element and resort
//    public mutating func updateElement(element: Source.Generator.Element, atIndex: Source.Index)
//    {
//        guard atIndex >= 0 && atIndex < self.count else{return;}
//        self.source[atIndex] = element;
//        self.updateElement(element, atIndex: atIndex);
//    }
//}

//MARK: ArrayHeap
//public struct ArrayHeap<T> {
//    
//    
//    //source type
//    public typealias Source = Array<T>;
//    
//    //heap type
//    typealias HeapType = HeapConvertor<Source>;
//    
//    //index type
//    public typealias Index = Source.Index;
//    
//    //heap data
//    private var heap: HeapType;
//    
//    //init
//    //sort according to isOrderedBefore
//    public init(isOrderedBefore:(Source.Generator.Element, Source.Generator.Element) -> Bool, source: Source? = nil)
//    {
//        self.heap = HeapType(source: source ?? [], isOrderedBefore: isOrderedBefore);
//    }
//    
//}
//
////extension SequenceType
//extension ArrayHeap: SequenceType
//{
//    public func generate() -> Source.Generator {
//        return self.heap.source.generate();
//    }
//}
//
////extension Indexable
//extension ArrayHeap: Indexable
//{
//    public var startIndex: Index{return self.heap.source.startIndex;}
//    public var endIndex: Index{return self.heap.source.endIndex;}
//    public subscript(position: Index) -> Source.Generator.Element{return self.heap.source[position];}
//}
//
////extension PrioritySequenceType
//extension ArrayHeap: PrioritySequenceType
//{
//    //count
//    public var count: Source.Index.Distance{return self.heap.source.count;}
//
//    //'self' is empty
//    public var isEmpty: Bool{return self.heap.source.isEmpty;}
//
//    //append element and resort
//    public mutating func insert(element: Source.Generator.Element)
//    {
//        self.heap.source.append(element);
//        self.heap.shiftUp(self.count - 1);
//    }
//
//    //return(and remove) first element and resort
//    public mutating func popBest() -> Source.Generator.Element?
//    {
//        if(self.isEmpty){return nil;}
//        let first = self.heap.source[0];
//        let end = self.heap.source.removeLast();
//        guard !self.isEmpty else{return first;}
//        self.heap.source[0] = end;
//        self.heap.shiftDown(0);
//        return first;
//    }
//
//    //update element and resort
//    public mutating func updateElement(element: Source.Generator.Element, atIndex: Source.Index)
//    {
//        guard atIndex >= 0 && atIndex < self.count else{return;}
//        self.heap[atIndex] = element;
//        self.updateElement(element, atIndex: atIndex);
//    }
//}
