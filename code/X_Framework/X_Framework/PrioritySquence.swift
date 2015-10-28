//
//  PrioritySquence.swift
//  X_Framework
//
//  Created by 173 on 15/10/28.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//MARK: PrioritySequence
public protocol PrioritySequence: SequenceType
{
    //Data source type
    typealias DataSource: MutableCollectionType;
    
    //generator
    typealias Generator = Self.DataSource.Generator;
    
    //source
    var source: Self.DataSource{get}
    
    //append element and resort
    mutating func insert(element: Self.Generator.Element)
    
    //return(and remove) first element and resort
    mutating func popBest() -> Self.Generator.Element?
    
    //update element and resort
    mutating func updateElement(element: Self.Generator.Element, atIndex: Self.DataSource.Index)
}
public extension PrioritySequence
{
    //count
    var count: Self.DataSource.Index.Distance{return self.source.count;}
    
    //is empty
    var isEmpty: Bool{return self.source.isEmpty;}
}
public extension PrioritySequence where Self.Generator == Self.DataSource.Generator
{
    func generate() -> Self.Generator {
        return self.source.generate();
    }
}

//MARK: priority sequence convertible
protocol PrioritySequenceProcessor
{
    //mutable collection type
    typealias MC: MutableCollectionType
    
    //trunkIndex
    func trunkIndex(index: Self.MC.Index) -> Self.MC.Index
    
    //branchIndex
    func branchIndex(index: Self.MC.Index) -> Self.MC.Index
    
    //shift up sequence element at index i use isOrderedBefore function
    //return nil when sequence no change
    @warn_unused_result
    func shiftUp(sequence: Self.MC, atIndex i: Self.MC.Index, isOrderedBefore iob: (Self.MC.Generator.Element, Self.MC.Generator.Element)->Bool) -> Self.MC?
    
    //shift down sequence element at index i use isOrderedBefore function
    //return nil when sequence no change
    @warn_unused_result
    func shiftDown(sequence: Self.MC, atIndex i: Self.MC.Index, isOrderedBefore iob: (Self.MC.Generator.Element, Self.MC.Generator.Element)->Bool) -> Self.MC?
    
    //update sequence element at index use isOrderedBefore functoin
    //return nil when collection no change
    @warn_unused_result
    func updateElement(sequence: Self.MC, element: Self.MC.Generator.Element, atIndex i: Self.MC.Index, isOrderedBefore iob: (Self.MC.Generator.Element, Self.MC.Generator.Element)->Bool) -> Self.MC?
    
    //build sequence to priority sequence use isOrderedBefore function
    //return nil when sequence no change
    @warn_unused_result
    func build(sequence: Self.MC, isOrderedBefore iob: (Self.MC.Generator.Element, Self.MC.Generator.Element)->Bool) -> Self.MC?
}
//extension where Index == Int
extension PrioritySequenceProcessor where Self.MC.Index == Int
{
    //element type
    private typealias _Ele = Self.MC.Generator.Element;
    
    //shift up sequence element at index i use isOrderedBefore function
    //return nil when sequence no change
    @warn_unused_result
    func shiftUp(sequence: Self.MC, atIndex i: Int, isOrderedBefore iob: (_Ele, _Ele)->Bool) -> Self.MC?
    {
        guard i > 0 else{return nil;}
        var _temp = sequence;
        var _bIndex = i;
        let _branch = _temp[_bIndex];
        repeat{
            let _tIndex = self.trunkIndex(_bIndex);
            let _trunk = _temp[_tIndex];
            guard iob(_branch, _trunk) else {break;}
            _temp[_bIndex] = _trunk;
            _temp[_tIndex] = _branch;
            _bIndex = _tIndex;
        }while _bIndex > 0
        return _temp;
    }
    
    //shift down sequence element at index i use isOrderedBefore function
    //return nil when sequence no change
    @warn_unused_result
    func shiftDown(sequence: Self.MC, atIndex i: Int, isOrderedBefore iob: (_Ele, _Ele)->Bool) -> Self.MC?
    {
        let _c = sequence.count;
        guard i < _c else{return nil;}
        var _temp = sequence;
        let _trunk = _temp[i];
        var _tIndex = i;
        repeat{
            var _tempIndex = _tIndex;
            var _childIndex = self.branchIndex(_tempIndex);
            guard _childIndex < _c else{break;}
            if iob(_temp[_childIndex], _trunk){_tempIndex = _childIndex;}
        
            _childIndex++;
            if _childIndex < _c && iob(_temp[_childIndex], _temp[_tempIndex]){_tempIndex = _childIndex;}
            
            guard _tempIndex != _tIndex else{break;}
            _temp[_tIndex] = _temp[_tempIndex];
            _temp[_tempIndex] = _trunk;
            _tIndex = _tempIndex;
        }while _tIndex < _c
        
        return _temp;
    }
    
    //update sequence element at index use isOrderedBefore functoin
    //return nil when collection no change
    @warn_unused_result
    func updateElement(sequence: Self.MC, element: _Ele, atIndex i: Int, isOrderedBefore iob: (_Ele, _Ele)->Bool) -> Self.MC?
    {
        let _c = sequence.count;
        guard i >= 0 && i < _c else{return nil;}
        var _temp = sequence;
        _temp[i] = element;
        let _parentIndex = self.trunkIndex(i);
        guard iob(element, _temp[_parentIndex]) else {
            return self.shiftDown(_temp, atIndex: i, isOrderedBefore: iob);
        }
        return self.shiftUp(_temp, atIndex: i, isOrderedBefore: iob);
    }
    
    //build sequence to priority sequence use isOrderedBefore function
    //return nil when sequence no change
    @warn_unused_result
    func build(sequence: Self.MC, isOrderedBefore iob: (_Ele, _Ele)->Bool) -> Self.MC?
    {
        var _index:Int = sequence.count >> 1 - 1;
        guard _index > -1 else{return nil;}
        var _temp = sequence;
        repeat{
            guard let newTemp = self.shiftDown(_temp, atIndex: _index--, isOrderedBefore: iob) else {continue;}
            _temp = newTemp;
        }while _index > -1
        return _temp;
    }
}



//MARK: PriorityArray struct
public struct PriorityArray<_Element>: PrioritySequence, PrioritySequenceProcessor
{
    //Data source type
    public typealias DataSource = Array<_Element>;
    
    //mutable collection tyupe
    typealias MC = DataSource;
    
    //source
    private(set) public var source: DataSource;
    
    //sort according to isOrderedBefore
    private let isOrderedBefore: (_Element, _Element) -> Bool;
    
    //init
    //sort according to isOrderedBefore
    public init(isOrderedBefore:(_Element, _Element) -> Bool, source:DataSource? = nil)
    {
        self.isOrderedBefore = isOrderedBefore;
        self.source = source ?? [];
        self.source = self.build(self.source, isOrderedBefore: isOrderedBefore) ?? [];
    }
}
extension PriorityArray
{
    //append element and resort
    mutating public func insert(element: DataSource.Element)
    {
        self.source.append(element);
        guard let temp = self.shiftUp(self.source, atIndex: self.count - 1, isOrderedBefore: self.isOrderedBefore) else {return;}
        self.source = temp;
    }
    
    //return(and remove) first element and resort
    mutating public func popBest() -> DataSource.Element?
    {
        if(isEmpty){return nil;}
        let first = self.source[0];
        let end = self.source.removeLast();
        guard !self.isEmpty else{return first;}
        self.source[0] = end;
        guard let temp = self.shiftDown(self.source, atIndex: 0, isOrderedBefore: self.isOrderedBefore) else {return first;}
        self.source = temp;
        return first;
    }
    
    //update element and resort
    mutating public func updateElement(element: DataSource.Element, atIndex: DataSource.Index)
    {
        guard atIndex >= 0 && atIndex < self.count else{return;}
        guard let temp = self.updateElement(self.source, element: element, atIndex: atIndex, isOrderedBefore: self.isOrderedBefore) else {return;}
        self.source = temp;
    }
    
    //trunkIndex
    func trunkIndex(index: Int) -> Int
    {
        return (index - 1) >> 1;
    }
    
    //branchIndex
    func branchIndex(index: Int) -> Int
    {
        return ((index << 1) + 1);
    }
}
//MARK: extension public
public extension PriorityArray where _Element: Comparable
{
    init(max source:[_Element])
    {
        self.init(isOrderedBefore: {return $0 < $1}, source: source);
    }
    
    init(min source:[_Element])
    {
        self.init(isOrderedBefore: {return $0 > $1}, source: source);

    }
}