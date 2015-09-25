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
    //rise up at index of sequence
    func _riseup(var sequence:[XPQElement], _ atIndex:Int) -> [XPQElement]{
        if atIndex < 1 { return sequence}
        var i = atIndex;
        let e = sequence[i];
        repeat{
            let p_i = self._getParentIndex(i);
            let p_e = sequence[p_i];
            if self.compare(e, p_e){ break }
            sequence[i] = p_e;
            sequence[p_i] = e;
            i = p_i;
        }while i > 0
        return sequence;
    }
    
    //sink down
    func _sinkdown(var sequence:[XPQElement], _ atIndex:Int) -> [XPQElement]{
        let c = sequence.count;
        var i = atIndex;
        let e = sequence[i];
        
        while true
        {
            var index = i;
            let left = self._getChildIndex(index);
            if left >= c {break;}
            let right = left + 1;
            
            var compareIndex = left;
            if right < c && self.compare(sequence[left], sequence[right])
            {
                compareIndex = right;
            }
            
            if self.compare(e, sequence[compareIndex]) { index = compareIndex; }
            if index == i {break;}
            sequence[i] = sequence[index];
            sequence[index] = e;
            i = index;
        }
        return sequence;
    }
    
    //update element at index
    func _update(var sequence:[XPQElement], _ element:XPQElement, _ atIndex:Int) -> [XPQElement]{
        if atIndex < 0 || atIndex > sequence.count { return sequence }
        sequence[atIndex] = element;
        let p_i = self._getParentIndex(atIndex);
        sequence = self.compare(element, sequence[p_i]) ? _sinkdown(sequence, atIndex):_riseup(sequence, atIndex);
        return sequence;
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
        self.rebuild(self.source);
    }
    
    mutating func push(element: T)
    {
        var temp = self.source;
        temp.append(element);
        self._source = self._riseup(temp, temp.count - 1);
    }
    
    mutating func pop() -> T? {
        if(isEmpty){return nil;}
        var temp = self.source;
        let first = temp[0];
        let end = temp.removeLast();
        if !temp.isEmpty
        {
            temp[0] = end;
            temp = _sinkdown(temp, 0);
        }
        self._source = temp;
        return first;
    }
    
    mutating func update(element: T, atIndex i: Int) {
        self[i] = element;
//        self._source = self._update(self.source, element, i);
    }
    
    mutating func rebuild(sequence: [XPQElement]) {
        var temp = sequence;
        var i = temp.count >> 1 - 1;
        while i > -1
        {
            temp = self._sinkdown(temp, i--);
        }
        self._source = temp;
    }
    
    private(set) subscript(i:Int) -> T{
        set{
            self._source = self._update(self.source, newValue, i);
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

