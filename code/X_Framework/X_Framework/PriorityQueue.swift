//
//  PriorityQueue.swift
//  X_Framework
//
//  Created by 173 on 15/10/21.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//MARK: binary heap collection type
public protocol BinaryHeapCollectionType
{
    //source Type
    typealias SourceType: MutableCollectionType;
    
    //source type
    var source: Self.SourceType{get}
    
    //append element and resort
    mutating func append(newElement: Self.SourceType.Generator.Element)
    
    //return(and remove) first element and resort
    mutating func popFirst() -> Self.SourceType.Generator.Element?
    
    //update element and resort
    mutating func updateElement(element: Self.SourceType.Generator.Element, atIndex: Self.SourceType.Index)
    
    //init
    init(isOrderedBefore:(Self.SourceType.Generator.Element, Self.SourceType.Generator.Element) -> Bool)
}
//MARK: extension CollectionType
public extension BinaryHeapCollectionType where Self: CollectionType
{
    public var startIndex: Self.SourceType.Index {return self.source.startIndex}
    public var endIndex: Self.SourceType.Index {return self.source.endIndex}
    public subscript(i: Self.SourceType.Index) -> Self.SourceType.Generator.Element{return self.source[i]}
}

//MARK: binary heap convertible
public protocol BinaryHeapConvertible
{
    //mutable collection type
    typealias SourceType: MutableCollectionType;
}
public extension BinaryHeapConvertible where Self.SourceType.Index == Int
{
    //element type
    private typealias _MCElement = Self.SourceType.Generator.Element;
    
    //shift up collection element at index i use isOrderedBefore function
    //return nil when collection no change
    @warn_unused_result
    static func shiftUp(collection: Self.SourceType, atIndex i: Int, isOrderedBefore iob: (_MCElement, _MCElement)->Bool) -> Self.SourceType?
    {
        guard i > 0 else{return nil;}
        var _temp = collection;
        var _index = i;
        let _ele = _temp[_index];
        repeat{
            let _parentIndex = Self.getParentIndex(ofChildIndex: _index);
            let _parent = _temp[_parentIndex];
            guard iob(_ele, _parent) else {break;}
            _temp[_index] = _parent;
            _temp[_parentIndex] = _ele;
            _index = _parentIndex;
        }while _index > 0
        
        return _temp;
    }
    
    //shift down collection element at index i use isOrderedBefore function
    //return nil when collection no change
    @warn_unused_result
    static func shiftDown(collection: Self.SourceType, atIndex i: Int, isOrderedBefore iob: (_MCElement, _MCElement)->Bool) -> Self.SourceType?
    {
        let _c = collection.count;
        guard i < _c else{return nil;}
        var _temp = collection;
        let _ele = _temp[i];
        var _index = i;
        repeat{
            var _tempIndex = _index;
            var _childIndex = Self.getChildIndex(ofParentIndex: _tempIndex);
            guard _childIndex < _c else{break;}
            if iob(_temp[_childIndex], _ele){_tempIndex = _childIndex;}
            
            _childIndex++;
            
            if _childIndex < _c && iob(_temp[_childIndex], _temp[_tempIndex]){_tempIndex = _childIndex;}
            
            guard _tempIndex != _index else{break;}
            _temp[_index] = _temp[_tempIndex];
            _temp[_tempIndex] = _ele;
            _index = _tempIndex;
        }while _index < _c
        
        return _temp;
    }
    
    //update collection element at index use isOrderedBefore functoin
    //return nil when collection no change
    @warn_unused_result
    static func updateElement(collection: Self.SourceType, element: _MCElement, atIndex i: Int, isOrderedBefore iob: (_MCElement, _MCElement)->Bool) -> Self.SourceType?
    {
        let _c = collection.count;
        guard i >= 0 && i < _c else{return nil;}
        var _temp = collection;
        _temp[i] = element;
        let _parentIndex = Self.getParentIndex(ofChildIndex: i);
        guard iob(element, _temp[_parentIndex]) else {
            return Self.shiftDown(_temp, atIndex: i, isOrderedBefore: iob);
        }
        return Self.shiftUp(_temp, atIndex: i, isOrderedBefore: iob);
    }
    
    //build collection to priority collection use isOrderedBefore function
    //return nil when collection no change
    @warn_unused_result
    static func build(collection: Self.SourceType, isOrderedBefore iob: (_MCElement, _MCElement)->Bool) -> Self.SourceType?
    {
        var _index:Int = collection.count >> 1 - 1;
        guard _index > -1 else{return nil;}
        var _temp = collection;
        repeat{
            guard let newTemp = Self.shiftDown(_temp, atIndex: _index--, isOrderedBefore: iob) else {continue;}
            _temp = newTemp;
        }while _index > -1
        return _temp;
    }
    
    //parent node index
    static func getParentIndex(ofChildIndex index:Int) -> Int{return (index - 1) >> 1;}
    
    //child node index(the left one, the mini index one)
    static func getChildIndex(ofParentIndex index:Int) -> Int{return ((index << 1) + 1);}
}

////MARK: binary heap convertible
//public protocol BinaryHeapConvertible
//{
//    //mutable collection type
//    typealias SourceType: MutableCollectionType;
//}
//public extension BinaryHeapConvertible where Self.SourceType.Index == Int
//{
//    //element type
//    private typealias _MCElement = Self.SourceType.Generator.Element;
//    
//    //shift up collection element at index i use isOrderedBefore function
//    //return nil when collection no change
//    @warn_unused_result
//    static func shiftUp(collection: Self.SourceType, atIndex i: Int, isOrderedBefore iob: (_MCElement, _MCElement)->Bool) -> Self.SourceType?
//    {
//        guard i > 0 else{return nil;}
//        var _temp = collection;
//        var _index = i;
//        let _ele = _temp[_index];
//        repeat{
//            let _parentIndex = Self.getParentIndex(ofChildIndex: _index);
//            let _parent = _temp[_parentIndex];
//            guard iob(_ele, _parent) else {break;}
//            _temp[_index] = _parent;
//            _temp[_parentIndex] = _ele;
//            _index = _parentIndex;
//        }while _index > 0
//        
//        return _temp;
//    }
//    
//    //shift down collection element at index i use isOrderedBefore function
//    //return nil when collection no change
//    @warn_unused_result
//    static func shiftDown(collection: Self.SourceType, atIndex i: Int, isOrderedBefore iob: (_MCElement, _MCElement)->Bool) -> Self.SourceType?
//    {
//        let _c = collection.count;
//        guard i < _c else{return nil;}
//        var _temp = collection;
//        let _ele = _temp[i];
//        var _index = i;
//        repeat{
//            var _tempIndex = _index;
//            var _childIndex = Self.getChildIndex(ofParentIndex: _tempIndex);
//            guard _childIndex < _c else{break;}
//            if iob(_temp[_childIndex], _ele){_tempIndex = _childIndex;}
//            
//            _childIndex++;
//            
//            if _childIndex < _c && iob(_temp[_childIndex], _temp[_tempIndex]){_tempIndex = _childIndex;}
//            
//            guard _tempIndex != _index else{break;}
//            _temp[_index] = _temp[_tempIndex];
//            _temp[_tempIndex] = _ele;
//            _index = _tempIndex;
//        }while _index < _c
//        
//        return _temp;
//    }
//    
//    //update collection element at index use isOrderedBefore functoin
//    //return nil when collection no change
//    @warn_unused_result
//    static func updateElement(collection: Self.SourceType, element: _MCElement, atIndex i: Int, isOrderedBefore iob: (_MCElement, _MCElement)->Bool) -> Self.SourceType?
//    {
//        let _c = collection.count;
//        guard i >= 0 && i < _c else{return nil;}
//        var _temp = collection;
//        _temp[i] = element;
//        let _parentIndex = Self.getParentIndex(ofChildIndex: i);
//        guard iob(element, _temp[_parentIndex]) else {
//            return Self.shiftDown(_temp, atIndex: i, isOrderedBefore: iob);
//        }
//        return Self.shiftUp(_temp, atIndex: i, isOrderedBefore: iob);
//    }
//    
//    //build collection to priority collection use isOrderedBefore function
//    //return nil when collection no change
//    @warn_unused_result
//    static func build(collection: Self.SourceType, isOrderedBefore iob: (_MCElement, _MCElement)->Bool) -> Self.SourceType?
//    {
//        var _index:Int = collection.count >> 1 - 1;
//        guard _index > -1 else{return nil;}
//        var _temp = collection;
//        repeat{
//            guard let newTemp = Self.shiftDown(_temp, atIndex: _index--, isOrderedBefore: iob) else {continue;}
//            _temp = newTemp;
//        }while _index > -1
//        return _temp;
//    }
//    
//    //parent node index
//    static func getParentIndex(ofChildIndex index:Int) -> Int{return (index - 1) >> 1;}
//    
//    //child node index(the left one, the mini index one)
//    static func getChildIndex(ofParentIndex index:Int) -> Int{return ((index << 1) + 1);}
//}