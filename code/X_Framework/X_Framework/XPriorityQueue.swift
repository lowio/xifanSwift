//
//  PriorityQueue.swift
//  xlib
//
//  Created by 173 on 15/8/31.
//  Copyright (c) 2015年 yeah. All rights reserved.
//

import Foundation

//MARK: priority queue protocol
protocol XPriorityQueueProtocol{
    //element typealias
    typealias XPQElement;
    
    /**init with compare funct
    [$0, $1] -- $0 in front of $1 return true;
    [$1, $0] -- $1 in front of $0 return false;
    **/
    init(compare:(XPQElement, XPQElement) -> Bool)
    
    //push element at end
    mutating func push(element:XPQElement)
    
    //get first element and remove it
    mutating func pop() -> XPQElement?
    
    //update element at index
    mutating func update(element:XPQElement, atIndex:Int)
    
    //return array
    func toArray() -> [XPQElement]
    
    //empty?
    var isEmpty:Bool{get}
    
    //elemet count
    var count:Int{get}
    
    //subscript get XPQElement
    subscript(i:Int) -> XPQElement{get}
}

/**
*MARK: store properties
*/
struct XPriorityQueue <T>{
    
    //array
    private var _source:[T];
    
    /**compare funct
    [$0, $1] -- $0 in front of $1 return true;
    [$1, $0] -- $1 in front of $0 return false;
    **/
    private let _compare:(T, T) -> Bool;
}

//MARK: extension XPriorityQueueProtocol
extension XPriorityQueue: XPriorityQueueProtocol
{
    typealias XPQElement = T;
    
    
    init(compare: (T, T) -> Bool)
    {
        self._compare = compare;
        self._source = [];
    }
    
    init(sequence:[T], withCompare: (T, T) -> Bool)
    {
        self.init(compare:withCompare);
        self._source = sequence;
        self._rebuild();
    }
    
    mutating func push(element: T)
    {
        self._source.append(element);
        _bubbleUP(self.count - 1);
    }
    
    mutating func pop() -> T? {
        if(isEmpty){return nil;}
        let first = self[0];
        let end = self._source.removeLast();
        if !isEmpty
        {
            self[0] = end;
            _sinkDown(0);
        }
        return first;
    }
    
    mutating func update(element: T, atIndex i: Int) {
        if i < 0 || i > count { return; }
        self[i] = element;
        let p_i = _getParentIndex(i);
        self._compare(element, self[p_i]) ? _sinkDown(i):_bubbleUP(i);
    }
    
    var isEmpty:Bool { return self._source.isEmpty; }
    var count:Int{ return self._source.count; }
    func toArray() -> [T] {
        return _source;
    }
    
    private(set) subscript(i:Int) -> T{
        set{
            self._source[i] = newValue;
        }
        get{
            return self._source[i];
        }
    }
}

//MARK: private method
//use private extension, not write private pre every private method
private  extension XPriorityQueue
{
    //parent node index
    func _getParentIndex(atIndex:Int) -> Int{return (atIndex - 1) >> 1;}
    
    //child node index(the left one, the mini index one)
    func _getChildIndex(atIndex:Int) -> Int{return ((atIndex << 1) + 1);}
    
    //swap two element position
    mutating func _swap(index:Int, _ withIndex:Int)
    {
        let e = self[index];
        self[index] = self[withIndex];
        self[withIndex] = e;
    }
    
    //bubble up at index
    mutating func _bubbleUP(atIndex:Int)
    {
        if atIndex < 1 { return; }
        var i = atIndex;
        let e = self[i];
        repeat{
            let p_i = self._getParentIndex(i);
            let p_e = self[p_i];
            if self._compare(e, p_e){ break; }
            self[i] = p_e;
            self[p_i] = e;
//            _swap(i, p_i);
            i = p_i;
        }while i > 0
    }
    
    //sink down at index
    mutating func _sinkDown(atIndex:Int)
    {
        let c = self.count;
        var i = atIndex;
        let e = self[i];
        
        while true
        {
            var index = i;
            
            let left = self._getChildIndex(index);
            if left >= c {break;}
            if self._compare(e, self[left]) { index = left; }
            
            
            let right = left + 1;
            if right < c && self._compare(self[index], self[right]) { index = right; }
            
            if index == i {break;}
            self[i] = self[index];
            self[index] = e;
//            _swap(i, index);
            i = index;
        }
    }
    
    //rebuilding queue
    mutating func _rebuild()
    {
        var i = self.count >> 1 - 1;
        while i > -1
        {
            self._sinkDown(i--);
        }
    }
}

//MARK: extension Printable
extension XPriorityQueue: CustomStringConvertible
{
    var description:String{
        return self._source.description;
    }
}