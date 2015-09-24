//
//  PriorityQueue.swift
//  xlib
//
//  Created by 173 on 15/8/31.
//  Copyright (c) 2015年 yeah. All rights reserved.
//

import Foundation

//MARK: XPriorityQueueProtocol
protocol XPriorityQueueProtocol:CustomStringConvertible
{
    typealias XPQElement;
    
    /**init with compare funct
    [$0, $1,...] -- $0 in front of $1 return true;
    [$1, $0,...] -- $1 in front of $0 return false;
    **/
    var compare:(XPQElement, XPQElement)->Bool{get};
    
    //source array
    var source:[XPQElement]{get}
    
    //element count
    var count:Int{get}
    
    //element count is 0
    var isEmpty:Bool{get}
    
    /**init with compare funct
    [$0, $1] -- $0 in front of $1 return true;
    [$1, $0] -- $1 in front of $0 return false;
    **/
    init(sequence:[XPQElement], compare:(XPQElement, XPQElement) -> Bool)
    
    //push element at end
    mutating func push(element:XPQElement)
    
    //get first element and remove it
    mutating func pop() -> XPQElement?
    
    //update element at index
    mutating func update(element:XPQElement, atIndex:Int)
    
    //rebuild sequence to priority queue, return priority sequence
    mutating func rebuild(sequence:[XPQElement])
    
    //subscript get XPQElement
    subscript(i:Int) -> XPQElement{get}
}

//MARK: XPriorityQueueProtocol default implementation
extension XPriorityQueueProtocol
{
    var count:Int{return self.source.count}
    
    var isEmpty:Bool{return self.source.isEmpty}
    
    var description:String{
        return self.source.description;
    }
}

//MARK: XPriorityQueueProtocol default implementation(private)
private extension XPriorityQueueProtocol
{
    //rise up
    func _riseup(atIndex:Int) -> [XPQElement]{
        if atIndex < 1 { return self.source}
        var i = atIndex;
        var temp = self.source;
        let e = temp[i];
        repeat{
            let p_i = self._getParentIndex(i);
            let p_e = temp[p_i];
            if self.compare(e, p_e){ break }
            temp[i] = p_e;
            temp[p_i] = e;
            i = p_i;
        }while i > 0
        return temp;
    }
    
    //sink down
    func _sinkdown(atIndex:Int) -> [XPQElement]{
        let c = self.count;
        var temp = self.source;
        var i = atIndex;
        let e = temp[i];
        
        while true
        {
            var index = i;
            let left = self._getChildIndex(index);
            if left >= c {break;}
            if self.compare(e, temp[left]) { index = left; }
            
            
            let right = left + 1;
            if right < c && self.compare(temp[index], temp[right]) { index = right; }
            
            if index == i {break;}
            temp[i] = temp[index];
            temp[index] = e;
            i = index;
        }
        return temp;
    }
    
    //update element at index
    func _update(element:XPQElement, atIndex:Int) -> [XPQElement]{
        if atIndex < 0 || atIndex > self.count { return self.source; }
        var temp = self.source;
        temp[atIndex] = element;
        let p_i = self._getParentIndex(atIndex);
        temp = self.compare(element, temp[p_i]) ? _sinkdown(atIndex):_riseup(atIndex);
        return temp;
    }
    
    //parent node index
    func _getParentIndex(atIndex:Int) -> Int{return (atIndex - 1) >> 1;}
    
    //child node index(the left one, the mini index one)
    func _getChildIndex(atIndex:Int) -> Int{return ((atIndex << 1) + 1);}
}

/**
*MARK: XPriorityQueue
*/
struct XPriorityQueue <T>{
    
    //array
    private var _source:[T];
    
    /**compare funct
    [$0, $1] -- $0 in front of $1 return true;
    [$1, $0] -- $1 in front of $0 return false;
    **/
    private var _compare:(T, T) -> Bool;
}

//MARK: extension XPriorityQueueProtocol
extension XPriorityQueue: XPriorityQueueProtocol
{
    typealias XPQElement = T;
    
    init(compare: (T, T) -> Bool)
    {
        self.init(sequence: [], compare:compare);
    }
    
    init(sequence:[XPQElement], compare:(XPQElement, XPQElement) -> Bool)
    {
        self._compare = compare;
        self._source = sequence;
        rebuild(self._source);
    }
    
    mutating func push(element: T)
    {
        self._source.append(element);
        self._source = self._riseup(self.count - 1);
    }
    
    mutating func pop() -> T? {
        if(isEmpty){return nil;}
        let first = self[0];
        let end = self._source.removeLast();
        if !isEmpty
        {
            self[0] = end;
            self._source = _sinkdown(0);
        }
        return first;
    }
    
    mutating func update(element: T, atIndex i: Int) {
        self._source = self._update(element, atIndex: i);
    }
    
    mutating func rebuild(sequence: [XPQElement]) {
        self._source = sequence;
        var i = self.count >> 1 - 1;
        while i > -1
        {
            self._source = self._sinkdown(i--);
        }
    }
    
    private(set) subscript(i:Int) -> T{
        set{
            self._source[i] = newValue;
        }
        get{
            return self._source[i];
        }
    }
    
    var source:[XPQElement]{
        return self._source;
    }
    
    var compare:(XPQElement, XPQElement) -> Bool{
        return self._compare;
    }
}

//MARK: private method
//use private extension, not write private pre every private method
private  extension XPriorityQueue
{
    //swap two element position
    func _swap(var array:[T], _ index:Int, _ withIndex:Int) -> [T]
    {
        let e = array[index];
        array[index] = array[withIndex];
        array[withIndex] = e;
        return array;
    }
}

