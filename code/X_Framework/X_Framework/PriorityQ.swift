//
//  PriorityQ.swift
//  X_Framework
//
//  Created by 173 on 15/10/10.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//MARK: priority queue type
public protocol PriorityQueueType
{
    //element type
    typealias _Element;
    
    //source; if you set source , call rebuild()
    var source:[Self._Element]{get set}
    
    //element count
    var count:Int{get}
    
    //element count == 0
    var isEmpty:Bool{get}
    
    //compare function
    var compare:(Self._Element, Self._Element) -> Bool{get};
    
    //init rebuild queue use source with compare function
    init(source:[Self._Element], compare:(Self._Element, Self._Element) -> Bool)

    //append element and resort
    mutating func append(newElement: Self._Element)
    
    //remove first element and resort
    mutating func removeFirst() -> Self._Element?
    
    //update element and resort
    mutating func update(newElement: Self._Element, atIndex: Int)
    
    //rebuild queue use source
    mutating func rebuild()
}

//MARK: extension public
public extension PriorityQueueType
{
    mutating func append(newElement: Self._Element) {
        self.source.append(newElement);
        self._shiftUp(self.count - 1);
    }
    
    mutating func removeFirst() -> Self._Element? {
        if(isEmpty){return nil;}
        let first = self[0];
        let end = self.source.removeLast();
        guard !self.isEmpty else{return first;}
        self[0] = end;
        guard self.count > 1 else{return first;}
        self._shiftDown(0);
        return first;
    }
    
    mutating func update(element: Self._Element, atIndex: Int) {
        guard atIndex >= 0 && atIndex < self.count else{return;}
        self[atIndex] = element;
        let p_i = self._getParentIndex(atIndex);
        self.compare(element, self[p_i]) ? self._shiftDown(atIndex) : self._shiftUp(atIndex);
    }
    
    mutating func rebuild() {
        var i = self.count >> 1 - 1;
        while i > -1
        {
            self._shiftDown(i--);
        }
    }
    
    var count:Int{return self.source.count;}
    var isEmpty:Bool{return self.source.isEmpty;}
}

//extension CustomStringConvertible
public extension PriorityQueueType where Self:CustomStringConvertible
{
    var description:String{return self.source.description;}
}

//extension indexof
public extension PriorityQueueType where _Element: Equatable
{
    //return element index
    func indexOf(element: Self._Element) -> Int?{
        return self.source.indexOf(element);
    }
}
public extension PriorityQueueType
{
    //return element index
    func indexOf(element:Self._Element, isEquals: (Self._Element, Self._Element) -> Bool) -> Int?
    {
        return self.source.indexOf{
            return isEquals(element, $0);
        }
    }
}

//extension init
public extension PriorityQueueType where _Element: Comparable
{
    init(max source:[Self._Element])
    {
        self.init(source: source){$0 < $1}
    }
    
    init(min source:[Self._Element])
    {
        self.init(source: source){$0 > $1}
    }
}
public extension PriorityQueueType
{
    init(compare:(Self._Element, Self._Element) -> Bool)
    {
        self.init(source: [], compare: compare);
    }
}

//MARK: extension private
private extension PriorityQueueType
{
    //subscript
    subscript(i:Int) -> Self._Element{
        set{
            self.source[i] = newValue;
        }
        get{
            return self.source[i];
        }
    }
    
    //shift up
    mutating func _shiftUp(atIndex:Int)
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
    mutating func _shiftDown(atIndex:Int)
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

//MARK: PriorityQueue -- priority queue struct
public struct PriorityQueue<T>
{
    //source data
    public var source:[T];
    
    //compare function
    private(set) public var compare:(_Element, _Element) -> Bool;
    
    //init with resource
    public init(source:[_Element], compare:(_Element, _Element) -> Bool)
    {
        self.compare = compare;
        self.source = source;
        self.rebuild();
    }
}

//MARK: extention PriorityQueueType
extension PriorityQueue: PriorityQueueType
{
    public typealias _Element = T;
}