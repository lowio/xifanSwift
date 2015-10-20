////
////  PathFinder2DImpl.swift
////  X_Framework
////
////  Created by 173 on 15/10/20.
////  Copyright © 2015年 yeah. All rights reserved.
////
//
//import Foundation
//
//struct BreadthFirst<T: Hashable>{
//    
//    //explored list
//    private(set) var exploredList: [T: T];
//
//    //opened list
//    private(set)var openedList: [T];
//
//    //path
//    private(set) var path:[T]?;
//    
//    //neighbors
//    private(set)var neighbors: PathFinderNeighbors;
//    
//    //start goal
//    var start, goal:_Node?;
//    
//    //current index
//    var currentIndex:Int = 0;
//    
//    
//    init(neighbors:PathFinderNeighbors)
//    {
//        self.neighbors = neighbors;
//        self.exploredList = [:];
//        self.openedList = [];
//    }
//}
////extension PathFinderType
//extension BreadthFirst: PathFinderType
//{
//    typealias _Node = T;
//    
//    //prepare for seaching
//    mutating func prepare(start: _Node, _ goal: _Node)
//    {
//        self.exploredList = [:];
//        self.openedList = [];
//        self.currentIndex = 0;
//    }
//    
//    //seach complete
//    mutating func completion(at node: _Node)
//    {
//        self.path = backtrace(node)
//    }
//    
//    //return next node for search
//    mutating func next() -> _Node?
//    {
//        guard currentIndex < self.openedList.count else{return nil;}
//        return self.openedList[currentIndex++];
//    }
//    
//    //set node explored and to be chained to parent
//    mutating func setExplored(node: _Node, chainedTo parent: _Node?)
//    {
//        self.openedList.append(node);
//        self.exploredList[node] = parent;
//    }
//    
//    //get node's parent
//    func getParentOf(node: _Node) -> _Node?
//    {
//        return self.exploredList[node];
//    }
//}
////extension BreadthFirstPathFinder
//extension BreadthFirst: BreadthFirstPathFinder
//{
//    typealias _Neighbor = T;
//    
//    func isExplored(node: _Neighbor) -> Bool
//    {
//        return self.exploredList.keys.contains(node);
//    }
//    
//    func getNeighbors(around node: _Neighbor) -> [_Neighbor]
//    {
//        return [];
//    }
//}