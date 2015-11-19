//
//  PriorityQueue.swift
//  X_Framework
//
//  Created by xifanGame on 15/10/28.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//MARK: == PriorityQueueTreeIndex ==
public protocol PriorityQueueTreeIndex {
    
    //size, 2,4,8....
    var size: Int{get}
    
    //return trunk index of index
    func trunkIndexOf(index: Int) -> Int
    
    //return branch index of index
    func branchIndexOf(index: Int) -> Int
}
extension PriorityQueueTreeIndex {
    //return trunk index of index
    public func trunkIndexOf(index: Int) -> Int {
        return (index - 1) / self.size;
    }
    
    //return branch index of index
    public func branchIndexOf(index: Int) -> Int {
        return index * self.size + 1;
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
    mutating func replaceElement(element: Self.Generator.Element, atIndex: Self.Index)
}

//MARK: == PriorityQueueDelegate ==
public struct PriorityQueueDelegate {
    
    //index convertor
    let indexConvertor: PriorityQueueTreeIndex;
    
    //init
    public init(indexConvertor: PriorityQueueTreeIndex) {
        self.indexConvertor = indexConvertor;
    }
    
    //shift up element at index
    public func shiftUp<C: MutableIndexable where C.Index == Int>(inout source: C, index: Int, _ isOrderedBefore:(C._Element, C._Element) -> Bool) {
        let shiftElement = source[index];
        var shiftIndex = index;
        let zero = source.startIndex;
        
        repeat{
            let trunkIndex = self.indexConvertor.trunkIndexOf(shiftIndex);
            guard trunkIndex >= zero else{break;}
            let trunkElement = source[trunkIndex];
            
            guard isOrderedBefore(shiftElement, trunkElement) else {break;}
            source[shiftIndex] = source[trunkIndex];
            source[trunkIndex] = shiftElement;
            shiftIndex = trunkIndex;
        }while true
    }
    
    //shift down element at index
    public func shiftDown<C: MutableIndexable where C.Index == Int>(inout source: C, index: Int, _ isOrderedBefore:(C._Element, C._Element) -> Bool) {
        let shiftElement = source[index];
        var trunkIndex = index;
        let end = source.endIndex;
        
        repeat{
            var shiftIndex = trunkIndex;
            var branchIndex = self.indexConvertor.branchIndexOf(shiftIndex);
            var branchCount = self.indexConvertor.size;
            
            repeat{
                guard branchCount > 0 && branchIndex < end else {break;}
                if isOrderedBefore(source[branchIndex], source[shiftIndex]) {
                    shiftIndex = branchIndex
                }
                branchCount--;
                branchIndex++;
            }while true
            
            guard shiftIndex != trunkIndex else{break;}
            source[trunkIndex] = source[shiftIndex];
            source[shiftIndex] = shiftElement;
            trunkIndex = shiftIndex;
        }while true;
    }
    
    //replace element at index
    public func replace<C: MutableIndexable where C.Index == Int>(inout source: C, index: Int, element: C._Element, _ isOrderedBefore:(C._Element, C._Element) -> Bool) {
        let trunkIndex = self.indexConvertor.trunkIndexOf(index);
        guard isOrderedBefore(element, source[trunkIndex]) else{
            self.shiftUp(&source, index: index, isOrderedBefore);
            return;
        }
        self.shiftDown(&source, index: index, isOrderedBefore);
    }
    
    //priority sequence use isOrderedBefore function
    public func build<C: MutableIndexable where C.Index == Int>(inout source: C, _ isOrderedBefore:(C._Element, C._Element) -> Bool) {
        guard source.endIndex > 1 else {return;}
        let zero = source.startIndex;
        var _index = self.indexConvertor.trunkIndexOf(source.endIndex - 1);
        repeat{
            self.shiftDown(&source, index: _index, isOrderedBefore);
            _index--;
        }while _index >= zero
    }
}

//MARK: == PriorityQueueBinary ==
public struct PriorityQueueBinary {
    private init(){}
    private struct _PQTreeIndex: PriorityQueueTreeIndex {
        //size, 2,4,8....
        let size = 2;
        
        //return trunk index of index
        func trunkIndexOf(index: Int) -> Int {
            return (index - 1) >> 1;
        }
        
        //return branch index of index
        func branchIndexOf(index: Int) -> Int {
            return index << 1 + 1;
        }
    }
    
    //binary priority queue delegate
    public static let delegate = PriorityQueueDelegate(indexConvertor: _PQTreeIndex());
}

//MARK: == PriorityQueue ==
public struct PriorityQueue<T>
{
    //base array
    private var base: [T];
    
    //sort according to isOrderedBefore
    private(set) var isOrderedBefore: (T, T) -> Bool;
    
    //delegate
    private var delegate: PriorityQueueDelegate {
        return PriorityQueueBinary.delegate;
    }
    
    //init
    public init(_ base: [T], _ isOrderedBefore: (T, T) -> Bool){
        self.base = base;
        self.isOrderedBefore = isOrderedBefore;
        self.delegate.build(&self.base, self.isOrderedBefore);
    }
    
    //init
    public init(_ isOrderedBefore: (T, T) -> Bool){
        self.init([], isOrderedBefore);
    }
}
//MARK: extension PriorityQueueType
extension PriorityQueue: PriorityQueueType {
    //append element and resort
    mutating public func insert(element: T)
    {
        self.base.append(element);
        self.delegate.shiftUp(&self.base, index: self.base.count - 1, self.isOrderedBefore);
    }
    
    //return(and remove) first element and resort
    mutating public func popBest() -> T?
    {
        if(self.base.isEmpty){return nil;}
        let first = self.base[0];
        let end = self.base.removeLast();
        guard !self.base.isEmpty else{return first;}
        self.base[0] = end;
        self.delegate.shiftDown(&self.base, index: 0, self.isOrderedBefore);
        return first;
    }
    
    //replace element at index
    public mutating func replaceElement(element: T, atIndex: Int)
    {
        self.delegate.replace(&self.base, index: atIndex, element: element, self.isOrderedBefore);
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
