//
//  XPriorityQ.swift
//  X_Framework
//
//  Created by 173 on 15/10/10.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//MARK: XPriorityQueueType --  priority queue type
protocol XPriorityQueueType: CustomStringConvertible
{
    //element type
    typealias _Element;
    
    //source
    var source:[Self._Element]{get}
    
    //elements count
    var count:Int{get}
    
    //elements is empty
    var isEmpty:Bool{get}
    
    //compare function
    var compare:(Self._Element, Self._Element) -> Bool{get};
    
    //subscript
    subscript(i:Int) -> Self._Element{get set}
    
    //push element
    mutating func push(element:Self._Element)
    
    //get first element
    mutating func pop() -> Self._Element?
    
    //update element at index
    mutating func update(element:Self._Element, atIndex:Int)
    
    //rebuild collection to priority queue
    mutating func rebuild(source:[Self._Element])
}

//MARK: XPriorityQueueType -- default implement
extension XPriorityQueueType
{
    var count:Int{return self.source.count;}
    var isEmpty:Bool{return self.source.isEmpty;}
    var description:String{return self.source.description;}
}

//MARK: XPriorityQueueType private default extension
private extension XPriorityQueueType
{
    //exchange element at elementIndex with withIndex
    mutating func _exchange(element:Self._Element, _ elementIndex:Int, _ withIndex:Int)
    {
        self[elementIndex] = self[withIndex];
        self[withIndex] = element;
    }
    
    //rise up
    mutating func _riseup(atIndex:Int)
    {
        if atIndex < 1 {return;}
        var i = atIndex;
        let e = self[atIndex];
        repeat{
            let p_i = self._getParentIndex(i);
            let p_e = self[p_i];
            if self.compare(e, p_e){ break; }
            self[i] = p_e;
            self[p_i] = e;
            i = p_i;
        }while i > 0
    }
    
    //sink down
    mutating func _sinkdown(atIndex:Int)
    {
        let c = self.count;
        var i = atIndex;
        let e = self[i];
        
        while true
        {
            var index = i;
            
            let li = self._getChildIndex(index);
            if li >= c{break;}
            if self.compare(e, self[li]){index = li;}
            
            let ri = li + 1;
            if ri < c && self.compare(self[index], self[ri]){index = ri;}
            
            if index == i {break;}
            self[i] = self[index];
            self[index] = e;
            i = index;
        }
    }
    
    //parent node index
    func _getParentIndex(atIndex:Int) -> Int{return (atIndex - 1) >> 1;}
    
    //child node index(the left one, the mini index one)
    func _getChildIndex(atIndex:Int) -> Int{return ((atIndex << 1) + 1);}
}


//MARK: XPriorityQ -- priority queue struct
struct XPriorityQueue<T>
{
    typealias _Element = T;
    
    //source data
    private(set) var source:[T];
    
    //compare function
    private(set) var compare:(T, T) -> Bool
    
    /**init with compare funct
    [$0, $1,...] -- $0 in front of $1 return true;
    [$1, $0,...] -- $1 in front of $0 return false;
    **/
    init(compare:(T, T) -> Bool)
    {
        self.init(source: [], compare: compare);
    }
    
    //init with resource
    init(source:[T], compare:(T, T) -> Bool)
    {
        self.compare = compare;
        self.source = source;
        rebuild(self.source);
    }
}


//MARK: XPriorityQ -- subscript
extension XPriorityQueue
{
    subscript(i:Int) -> T{
//        private(set) subscript(i:Int) -> T{
        set{
            self.source[i] = newValue;
        }
        get{
            return self.source[i];
        }
    }
}

//MARK: XPriorityQ -- extension XPriorityQueueType functions
extension XPriorityQueue: XPriorityQueueType
{
    mutating func push(element: T) {
        self.source.append(element);
        self._riseup(self.count - 1);
    }
    
    mutating func pop() -> T? {
        if(isEmpty){return nil;}
        let first = self[0];
        let end = self.source.removeLast();
        guard !self.isEmpty else{return first;}
        self[0] = end;
        guard self.count > 1 else{return first;}
        self._sinkdown(0);
        return first;
    }
    
    mutating func update(element: T, atIndex: Int) {
        guard atIndex >= 0 && atIndex < self.count else{return;}
        self[atIndex] = element;
        let p_i = self._getParentIndex(atIndex);
        self.compare(element, self[p_i]) ? self._sinkdown(atIndex) : self._riseup(atIndex);
    }
    
    mutating func rebuild(source: [T]) {
        self.source = source;
        var i = self.count >> 1 - 1;
        while i > -1
        {
            self._sinkdown(i--);
        }
    }
    
}


