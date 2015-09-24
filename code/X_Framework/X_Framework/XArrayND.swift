//
//  XArrayND.swift
//  xlib
//
//  Created by 173 on 15/9/16.
//  Copyright (c) 2015年 yeah. All rights reserved.
//

import Foundation

protocol XPQ
{
    typealias XPQElement;
    
    /**init with compare funct
    [$0, $1,...] -- $0 in front of $1 return true;
    [$1, $0,...] -- $1 in front of $0 return false;
    **/
    var compare:(XPQElement, XPQElement)->Bool{get};
    
    //source array
    var souce:[XPQElement]{get}
    
    //element count
    var count:Int{get}
    
    //element count is 0
    var isEmpty:Bool{get}
    
    //rebuild sequence to priority queue, return priority sequence
//    func rebuild(sequence:[XPQElement])
    
    
    
    //rise up element at index, return new sequeue
    static func riseup(sequence:Self, atIndex:Int) -> [Self.XPQElement]
    
    //sink down element at index, return new sequeue
    static func sinkdown(sequence:Self, atIndex:Int) -> [Self.XPQElement]
    
    //update element at index return new sequeue
    static func updateAt(sequence:Self, element:Self.XPQElement, atIndex:Int) -> [Self.XPQElement]
}

//MARK: extension instance value
extension XPQ
{
    var count:Int{return self.souce.count}
    
    var isEmpty:Bool{return self.souce.isEmpty}
    
//    func rebuild(sequence:[XPQElement]) -> [XPQElement]{
//        var i = self.count >> 1 - 1;
//        var temp:[XPQElement] = sequence;
//        while i > -1
//        {
//            temp = sinkdown(temp, atIndex: i--);
//        }
//        return temp;
//    }
    
    
}

//MARK: extension type value
extension XPQ
{
    static func riseup(sequence:Self, atIndex:Int) -> [Self.XPQElement]{
        if atIndex < 1 { return sequence.souce }
        var i = atIndex;
        var temp:[Self.XPQElement] = sequence.souce;
        let e = temp[i];
        repeat{
            let p_i = self._getParentIndex(i);
            let p_e = temp[p_i];
            if sequence.compare(e, p_e){ break; }
            temp[i] = p_e;
            temp[p_i] = e;
            i = p_i;
        }while i > 0
        return temp;
    }
    
    static func sinkdown(sequence:Self, atIndex:Int) -> [Self.XPQElement]{
        let c = sequence.count;
        var temp:[Self.XPQElement] = sequence.souce;
        var i = atIndex;
        let e = temp[i];
        
        while true
        {
            var index = i;
            let left = self._getChildIndex(index);
            if left >= c {break;}
            if sequence.compare(e, temp[left]) { index = left; }
            
            
            let right = left + 1;
            if right < c && sequence.compare(temp[index], temp[right]) { index = right; }
            
            if index == i {break;}
            temp[i] = temp[index];
            temp[index] = e;
            i = index;
        }
        return temp;
    }
    
    static func updateAt(sequence:Self, element:Self.XPQElement, atIndex:Int) -> [Self.XPQElement]{
        if atIndex < 0 || atIndex > sequence.count { return sequence.souce; }
        var temp:[Self.XPQElement] = sequence.souce;
        temp[atIndex] = element;
        let p_i = self._getParentIndex(atIndex);
        temp = sequence.compare(element, temp[p_i]) ? sinkdown(sequence, atIndex: atIndex):riseup(sequence, atIndex: atIndex);
        return temp;
    }
}

//MARK: private type value
private extension XPQ
{
    //parent node index
    static func _getParentIndex(atIndex:Int) -> Int{return (atIndex - 1) >> 1;}
    
    //child node index(the left one, the mini index one)
    static func _getChildIndex(atIndex:Int) -> Int{return ((atIndex << 1) + 1);}
}
