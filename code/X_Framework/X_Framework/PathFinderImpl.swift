//
//  PathFinderImpl.swift
//  X_Framework
//
//  Created by 叶贤辉 on 15/11/7.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//MARK: == PriorityPFinder ==
public protocol PriorityPFinderType: PFinderProcessor
{
    //open list
    var openList: BinaryPriorityQueue<Self.Element>! {get set}
    
    //visite list
    var visiteList: [Self.Element.Position: Self.Element]! {get set}
}
extension PriorityPFinderType
{
    public mutating func popBest() -> Self.Element? {
        return self.openList.popBest();
    }
    
    public subscript(position: Self.Element.Position) -> Self.Element? {
        set{
            guard let element = newValue else {return;}
            guard !element.isClosed else{
                self.visiteList[position] = element;
                return;
            }
            
            self.openList.insert(element);
            self.visiteList[position] = element;
        }
        get{
            return self.visiteList[position];
        }
    }
}

//MARK: == GreedyBestPFinder ==
public struct GreedyBestPFinder<T: PFinderSingleRequest>
{
    public typealias Element = PFinderHElement<T.Position>;
    
    public typealias Request = T;
    
    //is complete
    public private(set) var isComplete:Bool = false;
    
    //request
    public private(set) var request: T!;
    
    //open list
    public var openList: BinaryPriorityQueue<Element>!;
    
    //visite list
    public var visiteList: [T.Position: Element]!;
    
    //return h value
    private func heuristic(position: T.Position, _ andPosition: T.Position) -> CGFloat
    {
        return self.request.heuristicOf(position, andPosition);
    }
    
}
extension GreedyBestPFinder: PriorityPFinderType
{
    //position is goal
    public mutating func isGoal(position: T.Position) -> Bool {
        guard position == self.request.goal else {return false;}
        self.isComplete = true;
        return true;
    }
    
    //return neighbors of position
    public func neighborsOf(position: T.Position) -> [T.Position]{
        return self.request.neighborsOf(position);
    }
    
    //search position
    public mutating func searchOf(position: T.Position, _ parent: Element?) -> Element?{
        guard let _ = self[position] else {
            return Element(h: self.heuristic(position, self.request.goal), position: position, parent: parent as? PFinderChainable);
        }
        return nil;
    }
    
    public mutating func find(request: T, findOne: ([T.Position]) -> (), completion: (() -> ())?) {
        self.openList = BinaryPriorityQueue<Element>{return $0.h < $1.h;}
        self.visiteList = [:];
        self.request = request;
        self.searching(self.request.start, findOne: findOne, completion: completion);
    }
}



//MARK: == AstarPFinder ==
public struct AstarPFinder<T: PFinderSingleRequest>
{
    public typealias Element = PFinderFElement<T.Position>;
    
    public typealias Request = T;
    
    //is complete
    public private(set) var isComplete:Bool = false;
    
    //request
    public private(set) var request: T!;
    
    //open list
    public var openList: BinaryPriorityQueue<Element>!;
    
    //visite list
    public var visiteList: [T.Position: Element]!;
}
extension AstarPFinder: PriorityPFinderType
{
    //position is goal
    public mutating func isGoal(position: T.Position) -> Bool {
        guard position == self.request.goal else {return false;}
        self.isComplete = true;
        return true;
    }
    
    //return neighbors of position
    public func neighborsOf(position: T.Position) -> [T.Position]{
        return self.request.neighborsOf(position);
    }
    
    //search position
    public mutating func searchOf(position: T.Position, _ parent: Element?) -> Element?{
        let h = self.request.heuristicOf(position, self.request.goal);
        guard let p = parent else{
            return Element(h: h, position: position, parent: nil);
        }

        let g = p.g + self.request.costBetween(p.position, and: position)
        guard let visited = self[position] else {
            return Element(g: g, h: h, position: position, parent: p);
        }
        guard !visited.isClosed && g < visited.g else {return nil;}

        var element = visited;
        element.setParent(p, g: g);
        guard let i = (self.openList.indexOf{return $0.position == element.position;})else{return nil;}
        self.openList.replaceElement(element, atIndex: i);
        self.visiteList[element.position] = element;
        return nil;
    }
    
    public mutating func find(request: T, findOne: ([T.Position]) -> (), completion: (() -> ())?) {
        self.openList = BinaryPriorityQueue<Element>{return $0.f < $1.f;}
        self.visiteList = [:];
        self.request = request;
        self.searching(self.request.start, findOne: findOne, completion: completion);
    }
}

//MARK: == DijkstraPFinder ==
public struct DijkstraPFinder<T: PFinderMultiRequest>
{
    public typealias Element = PFinderFElement<T.Position>;
    
    public typealias Request = T;
    
    //is complete
    public var isComplete:Bool{return self.goals.isEmpty}
    
    //goals
    private var goals: [T.Position]!;
    
    //request
    public private(set) var request: T!;
    
    //open list
    public var openList: BinaryPriorityQueue<Element>!;
    
    //visite list
    public var visiteList: [T.Position: Element]!;
}
extension DijkstraPFinder: PriorityPFinderType
{
    //position is goal
    public mutating func isGoal(position: T.Position) -> Bool {
        
        guard let i = self.goals.indexOf(position) else {return false;}
        self.goals.removeAtIndex(i);
        return true;
    }
    
    //return neighbors of position
    public func neighborsOf(position: T.Position) -> [T.Position]{
        return self.request.neighborsOf(position);
    }
    
    //search position
    public mutating func searchOf(position: T.Position, _ parent: Element?) -> Element?{
        guard let p = parent else{
            return Element(g: 0, position: position, parent: nil);
        }
        
        let g = p.g + self.request.costBetween(p.position, and: position)
        guard let visited = self[position] else {
            return Element(g: g, position: position, parent: p);
        }
        guard !visited.isClosed && g < visited.g else {return nil;}
        
        var element = visited;
        element.setParent(p, g: g);
        guard let i = (self.openList.indexOf{return $0.position == element.position;})else{return nil;}
        self.openList.replaceElement(element, atIndex: i);
        self.visiteList[element.position] = element;
        return nil;
    }
    
    public mutating func find(request: T, findOne: ([T.Position]) -> (), completion: (() -> ())?) {
        self.openList = BinaryPriorityQueue<Element>{return $0.g < $1.g;}
        self.visiteList = [:];
        self.request = request;
        self.goals = self.request.goals;
        self.searching(self.request.start, findOne: findOne, completion: completion);
    }
}


/**
    next:
    breadthfirst
    T ->

*/



