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
    
    //source; if you set source , call rebuild()
    var source:[Self._Element]{get set}
    
    //compare function
    var compare:(Self._Element, Self._Element) -> Bool{get};
    
    //init rebuild queue use source with compare function
    init(source:[Self._Element], compare:(Self._Element, Self._Element) -> Bool)

    mutating func push(element: Self._Element)
    mutating func pop() -> Self._Element?
    mutating func update(element: Self._Element, atIndex: Int)
    mutating func rebuild()
}

//MARK: XPriorityQueueType extension -- default implement
extension XPriorityQueueType
{
    //compare function type
    typealias _XCompareFunction = (Self._Element, Self._Element) -> Bool
    
    init(compare:_XCompareFunction)
    {
        self.init(source: [], compare: compare);
    }
    
    mutating func push(element: Self._Element) {
        self.source.append(element);
        self._riseup(self.count - 1);
    }
    
    mutating func pop() -> Self._Element? {
        if(isEmpty){return nil;}
        let first = self[0];
        let end = self.source.removeLast();
        guard !self.isEmpty else{return first;}
        self[0] = end;
        guard self.count > 1 else{return first;}
        self._sinkdown(0);
        return first;
    }
    
    mutating func update(element: Self._Element, atIndex: Int) {
        guard atIndex >= 0 && atIndex < self.count else{return;}
        self[atIndex] = element;
        let p_i = self._getParentIndex(atIndex);
        self.compare(element, self[p_i]) ? self._sinkdown(atIndex) : self._riseup(atIndex);
    }
    
    mutating func rebuild() {
        var i = self.count >> 1 - 1;
        while i > -1
        {
            self._sinkdown(i--);
        }
    }
    
    var count:Int{return self.source.count;}
    var isEmpty:Bool{return self.source.isEmpty;}
    var description:String{return self.source.description;}
}

//MARK: XPriorityQueueType extension
extension XPriorityQueueType
{
    private(set) subscript(i:Int) -> Self._Element{
        set{
            self.source[i] = newValue;
        }
        get{
            return self.source[i];
        }
    }
}

//indexof
extension XPriorityQueueType where _Element: Equatable
{
    //get index
    func indexOf(ele:Self._Element) -> Int?{
        return self.source.indexOf(ele);
    }
}

//MARK: XPriorityQueueType extension -- private default implement
private extension XPriorityQueueType
{
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


//MARK: XPriorityQueue -- priority queue struct
struct XPriorityQueue<T>
{
    //source data
    var source:[T];
    
    //compare function
    private(set) var compare:XPriorityQueue._XCompareFunction
    
    //init with resource
    init(source:[T], compare:XPriorityQueue._XCompareFunction)
    {
        self.compare = compare;
        self.source = source;
        rebuild();
    }
}

//MARK: XPriorityQueue -- implement XPriorityQueueType
extension XPriorityQueue: XPriorityQueueType
{
    typealias _Element = T;
}