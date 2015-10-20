//
//  PathFinder2DImpl.swift
//  X_Framework
//
//  Created by 173 on 15/10/20.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//===============================================================================
//BreadthFirstQueue
struct BreadthFirstQueue<T: Hashable>{
    
    //key came from value
    private(set) var camefrom: [T: T];

    //opened list
    private(set)var openedList: [T];
    
    //current index
    private(set) var currentIndex:Int = 0;
    
    init()
    {
        self.camefrom = [:];
        self.openedList = [];
    }
}
//extension PathFinderOprator
extension BreadthFirstQueue: PathFinderQueue
{
    typealias _Element = T;
    
    //append visited element
    mutating func append(visited element: _Element, chainTo parent: _Element?) -> Bool
    {
        self.openedList.append(element);
        self.camefrom[element] = parent;
        return true;
    }
    
    //pop visited element
    mutating func pop() -> _Element?
    {
        guard currentIndex < self.openedList.count else{return nil;}
        return self.openedList[currentIndex++];
    }
    
    //set closed
    mutating func setClosed(element: _Element){}
    
    //is closed
    func isClosed(element: _Element) -> Bool
    {
        return self.camefrom.keys.contains(element);
    }
}