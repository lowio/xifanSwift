//
//  PathFinderImpl.swift
//  X_Framework
//
//  Created by xifanGame on 15/11/7.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//MARK: == PFPriorityQueue ==
public struct PFPriorityQueue<T: Hashable>{
    
    public typealias Element = PFinderElement<T>
    
    //open list
    private var openList: PriorityQueue<Element>;
    
    //visite list
    private var visiteList: [T: Element];
    
    init(isOrderedBefore:(Element, Element) -> Bool){
        self.openList = PriorityQueue(isOrderedBefore);
        self.visiteList = [:];
    }
}
extension PFPriorityQueue: PathFinderQueueType{
    //insert element
    mutating public func insert(element: Element){
        self.openList.insert(element);
        self.visiteList[element.position] = element;
    }
    
    //pop best element
    mutating public func popBest() -> Element?{
        return self.openList.popBest();
    }
    
    //close element
    mutating public func closeElement(element: Element){
        self.visiteList[element.position] = element;
    }
    
    //return element at position
    public func getElementAt(position: Element.Position) -> Element?{
        return self.visiteList[position];
    }
}

////MARK: == GreedyBestPFinder ==
//public struct GreedyBestPFinder<T: PathFinderRequestType>
//{
//    public typealias Element = PFinderElement<T.Position>;
//    
//    //goal point
//    private var goal: T.Position!;
//    
//    //queue
//    var queue: PFPriorityQueue<T.Position>!;
//    
//    //request
//    var request: T!;
//    
//    //init
//    public init(request: T)
//    {
//        self.request = request;
//    }
//}
//extension GreedyBestPFinder: PathFinderType
//{
//    public mutating func preparation(start: T.Position, goal: T.Position) {
//        self.goal = goal;
//        self.openList = PriorityQueue<Element>{return $0.h < $1.h;}
//    }
//    
//    //search position
//    public mutating func searchOf(position: T, _ parent: Element?) -> Element?{
//        print("WARN: =======================check walkable");
//        guard let _ = self[position] else {
//            let h = self.heuristicOf(position, self.goal);
//            guard let p = parent else{
//                return Element(g: 0, h: h, position: position, parent: nil);
//            }
//            return Element(g: 0, h: h, position: position, parent: p);
//        }
//        return nil;
//    }
//}
//
////MARK: == AstarPFinder ==
//public struct AstarPFinder<T: Hashable>
//{
//    public typealias Element = PFinderElement<T>;
//    
//    //open list
//    public var openList: PriorityQueue<Element>!;
//    
//    //visite list
//    public var visiteList: [T: Element]!;
//    
//    //goal point
//    private var goal: T!;
//    
//    //valid neighbors of $0
//    public let neighborsOf: (T) -> [T];
//    
//    //cost between $0 and $1, if unweight of g return 0
//    public let costOf: (T, T) -> CGFloat;
//    
//    //heuristic h value between $0 and $1, if unweight h return 0
//    public let heuristicOf: (T, T) -> CGFloat;
//    
//    //init
//    public init(neighborsOf: (T) -> [T], heuristicOf: (T, T) -> CGFloat, costOf: (T, T) -> CGFloat)
//    {
//        self.heuristicOf = heuristicOf;
//        self.costOf = costOf;
//        self.neighborsOf = neighborsOf;
//    }
//}
//extension AstarPFinder: PriorityPFinderType{}
//extension AstarPFinder: PFinderProcessor
//{
//    public mutating func preparation(start: T, goal: T) {
//        self.goal = goal;
//        self.openList = PriorityQueue<Element>{return $0.f < $1.f;}
//        self.visiteList = [:];
//    }
//    
//    //search position
//    public mutating func searchOf(position: T, _ parent: Element?) -> Element?{
//        print("WARN: =======================check walkable");
//        
//        let h = self.heuristicOf(position, self.goal);
//        guard let p = parent else{
//            return Element(g: 0, h: h, position: position, parent: nil);
//        }
//
//        let g = p.g + self.costOf(p.position, position)
//        guard let visited = self[position] else {
//            return Element(g: g, h: h, position: position, parent: p);
//        }
//        guard !visited.isClosed && g < visited.g else {return nil;}
//
//        var element = visited;
//        element.setParent(p, g: g);
//        guard let i = (self.openList.indexOf{return $0.position == element.position;})else{return nil;}
//        self.openList.replaceElement(element, atIndex: i);
//        self.visiteList[element.position] = element;
//        return nil;
//    }
//}
//
//
//
////MARK: == DijkstraPFinder ==
//public struct DijkstraPFinder<T: Hashable>
//{
//    public typealias Element = PFinderElement<T>;
//    
//    //open list
//    public var openList: PriorityQueue<Element>!;
//    
//    //visite list
//    public var visiteList: [T: Element]!;
//    
//    //goal point
//    private var goal: T!;
//    
//    //valid neighbors of $0
//    public let neighborsOf: (T) -> [T];
//    
//    //cost between $0 and $1, if unweight of g return 0
//    public let costOf: (T, T) -> CGFloat;
//    
//    //heuristic h value between $0 and $1, if unweight h return 0
//    public let heuristicOf: (T, T) -> CGFloat = {_,_ in 0};
//    
//    //init
//    public init(neighborsOf: (T) -> [T], costOf: (T, T) -> CGFloat)
//    {
//        self.costOf = costOf;
//        self.neighborsOf = neighborsOf;
//    }
//}
//extension DijkstraPFinder: PriorityPFinderType{}
//extension DijkstraPFinder: PFinderMultiProcessor
//{
//    public mutating func preparation(start: T, goal: T) {
//        self.goal = goal;
//        self.openList = PriorityQueue<Element>{return $0.f < $1.f;}
//        self.visiteList = [:];
//    }
//    
//    //search position
//    public mutating func searchOf(position: T, _ parent: Element?) -> Element?{
//        print("WARN: =======================check walkable");
//        guard let p = parent else{
//            return Element(g: 0, h: 0, position: position, parent: nil);
//        }
//        
//        let g = p.g + self.costOf(p.position, position)
//        guard let visited = self[position] else {
//            return Element(g: g, h: 0, position: position, parent: p);
//        }
//        guard !visited.isClosed && g < visited.g else {return nil;}
//        
//        var element = visited;
//        element.setParent(p, g: g);
//        guard let i = (self.openList.indexOf{return $0.position == element.position;})else{return nil;}
//        self.openList.replaceElement(element, atIndex: i);
//        self.visiteList[element.position] = element;
//        return nil;
//    }
//}
//
////MARK: == BreadthBestPFinder ==
//public struct BreadthBestPFinder<T: Hashable>
//{
//    public typealias Element = PFinderElement<T>;
//    
//    //open list
//    public var openList: [Element]!;
//    
//    //visite list
//    public var visiteList: [T: Element]!;
//    
//    //current index
//    private var currentIndex: Int = 0;
//    
//    //goal point
//    private var goal: T!;
//    
//    //valid neighbors of $0
//    public let neighborsOf: (T) -> [T];
//    
//    //cost between $0 and $1, if unweight of g return 0
//    public let costOf: (T, T) -> CGFloat = {_,_ in 0};
//    
//    //heuristic h value between $0 and $1, if unweight h return 0
//    public let heuristicOf: (T, T) -> CGFloat = {_,_ in 0};
//    
//    //init
//    public init(neighborsOf: (T) -> [T])
//    {
//        self.neighborsOf = neighborsOf;
//    }
//    
//}
//extension BreadthBestPFinder: PFinderMultiProcessor
//{
//    public mutating func popBest() -> Element? {
//        guard currentIndex < self.openList.count else{return nil;}
//        return self.openList[self.currentIndex++];
//    }
//    
//    public subscript(position: T) -> Element? {
//        set{
//            guard let element = newValue else {return;}
//            guard !element.isClosed else{
//                self.visiteList[position] = element;
//                return;
//            }
//            
//            self.openList.append(element);
//            self.visiteList[position] = element;
//        }
//        get{
//            return self.visiteList[position];
//        }
//    }
//    public mutating func preparation(start: T, goal: T) {
//        self.goal = goal;
//        self.openList = []
//        self.visiteList = [:];
//    }
//    
//    //search position
//    public mutating func searchOf(position: T, _ parent: Element?) -> Element?{
////        print("WARN: =======================check walkable");
//        guard let _ = self[position] else {
//            guard let p = parent else{
//                return Element(g: 0, h: 0, position: position, parent: nil);
//            }
//            return Element(g: 0, h: 0, position: position, parent: p);
//        }
//        return nil;
//    }
//}