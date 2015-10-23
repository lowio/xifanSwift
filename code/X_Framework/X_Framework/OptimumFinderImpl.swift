//
//  OptimumFinderImpl.swift
//  X_Framework
//
//  Created by 叶贤辉 on 15/10/23.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//BreadthFirst finder queue
public struct BreadthFirstFinderQueue<Element: FinderComparable> {
    
    //key came from value
    private(set) var camefrom: [Element._Point: Element];
    
    //opened list
    private(set)var openedList: [Element];
    
    //last pop element
    private var lastPop: Element?;
    
    //current index
    private var currentIndex:Int = 0;
    
    init()
    {
        self.camefrom = [:];
        self.openedList = [];
    }
}
extension BreadthFirstFinderQueue: FinderQueue
{
    //if point is visited return element else return nil
    public func getVisited(point: Element._Point) -> Element?
    {
        return self.camefrom[point];
    }
    
    //set element visited
    mutating public func setVisited(element: Element)
    {
        self.camefrom[element.point!] = element;
    }
    
    //pop optimum element
    mutating public func popFirst() -> Element?
    {
        guard currentIndex < self.openedList.count else{return nil;}
        lastPop = self.openedList[currentIndex++];
        return lastPop;
    }
    
    //appen element
    mutating public func append(element: Element)
    {
        self.openedList.append(element);
    }
    
    //update element
    mutating public func update(element: Element) -> Bool
    {
        guard let index = (self.openedList.indexOf{return element.point! == $0.point!})else{return false;}
        self.openedList[index] = element;
        return true;
    }
    
    //create 'Self'
    static public func create() -> BreadthFirstFinderQueue
    {
        return BreadthFirstFinderQueue();
    }
}
extension BreadthFirstFinderQueue where Element: Equatable
{
    //update element
    mutating func update(element: Element) -> Bool
    {
        guard let index = (self.openedList.indexOf(element))else{return false;}
        self.openedList[index] = element;
        return true;
    }
}