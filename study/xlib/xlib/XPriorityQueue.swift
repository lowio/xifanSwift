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
    init(compare:(XPQElement, XPQElement) -> Bool);
    
    /**
    build queue use source array use compare func
    */
    init(source:[XPQElement], withCompare:(XPQElement, XPQElement) -> Bool);
    
    //push element at end
    mutating func push(element:XPQElement) -> XPQElement;
    
    //get first element and remove it
    mutating func pop() -> XPQElement?;
    
    //update element at index
    mutating func update(element:XPQElement, atIndex:Int) -> XPQElement;
    
    //return element at index
    func getElement(atIndex:Int) -> XPQElement;
    
    //return array
    func toArray() -> [XPQElement];
    
    //empty?
    var isEmpty:Bool{get};
    
    //elemet count
    var count:Int{get}
}

/**
*MARK: store properties
*/
struct XPriorityQueue <T>{
    
    //array
    private var source:[T];
    
    /**compare funct
    [$0, $1] -- $0 in front of $1 return true;
    [$1, $0] -- $1 in front of $0 return false;
    **/
    private var compare:(T, T) -> Bool;
}

//MARK: extension XPriorityQueueProtocol
extension XPriorityQueue: XPriorityQueueProtocol
{
    typealias XPQElement = T;
    
    init(compare: (XPQElement, XPQElement) -> Bool)
    {
        self.compare = compare;
        self.source = [];
    }
    
    init(source:[XPQElement], withCompare:(XPQElement, XPQElement) -> Bool)
    {
        self.source = source;
        self.compare = withCompare;
        rebuild();
    }
    
    
    mutating func push(element: XPQElement) -> XPQElement {
        self.source.append(element);
        bubbleUP(self.count - 1);
        return element;
    }
    
    mutating func pop() -> XPQElement? {
        if(isEmpty){return nil;}
        let first = self.source.first;
        let end = self.source.removeLast();
        if !isEmpty
        {
            self.source[0] = end;
            sinkDown(0);
        }
        return first;
    }
    
    func getElement(atIndex: Int) -> XPQElement {return self.source[atIndex];}
    
    mutating func update(element: XPQElement, atIndex: Int) -> XPQElement {
        self.source[atIndex] = element;
        let p_i = getParentIndex(atIndex);
        self.compare(element, getElement(p_i)) ? sinkDown(atIndex):bubbleUP(atIndex);
        return element;
    }
    
    var isEmpty:Bool { return self.source.isEmpty; }
    var count:Int{ return self.source.count; }
    func toArray() -> [XPQElement] {
        return source;
    }
    
}

//MARK: private method
//use private extension, not write private pre every private method
private extension XPriorityQueue
{
    //parent node index
    func getParentIndex(atIndex:Int) -> Int{return (atIndex - 1) >> 1;}
    
    //child node index(the left one, the mini index one)
    func getChildIndex(atIndex:Int) -> Int{return ((atIndex << 1) + 1);}
    
    //swap two element position
    mutating func swap(index:Int, withIndex:Int)
    {
        let e = getElement(index);
        self.source[index] = self.source[withIndex];
        self.source[withIndex] = e;
    }
    
    //bubble up at index
    mutating func bubbleUP(atIndex:Int)
    {
        var i = atIndex;
        let e = self.getElement(i);
        while i > 0
        {
            let p_i = self.getParentIndex(i);
            let p_e = self.getElement(p_i);
            if(self.compare(e, p_e)){ break; }
            self.source[i] = p_e;
            self.source[p_i] = e;
//            swap(i, withIndex: p_i);
            i = p_i;
        }
    }
    
    //sink down at index
    mutating func sinkDown(atIndex:Int)
    {
        let c = self.count;
        var i = atIndex;
        let e = getElement(i);
        
        while true
        {
            var index = i;
            
            let left = self.getChildIndex(index);
            if left >= c {break;}
            if self.compare(e, getElement(left)) { index = left; }
            
            
            let right = left + 1;
            if right < c && self.compare(getElement(index), getElement(right)) { index = right; }
            
            if index == i {break;}
            self.source[i] = getElement(index);
            self.source[index] = e;
//            swap(i, withIndex: index);
            i = index;
        }
    }
    
    //rebuilding queue use source
    mutating func rebuild() {
        let c = self.count;
        if c < 2 {return;}
        var i = self.count >> 1 - 1;
        
        while i > -1
        {
            var index = i;
            let e = getElement(i);
            let left = getChildIndex(i);
            if self.compare(e, getElement(left)) {index = left;}
            
            let right = left + 1;
            if right < c && self.compare(getElement(index), getElement(right)){index = right;}
            
            if index != i {bubbleUP(index);}
            i--;
        }
    }
}

//MARK: extension Printable
extension XPriorityQueue: Printable
{
    var description:String{
        return self.source.description;
    }
}