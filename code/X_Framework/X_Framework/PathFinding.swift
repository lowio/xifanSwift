//
//  PathFinding.swift
//  X_Framework
//
//  Created by 173 on 15/11/25.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//
//
//public struct PathFinder {
//    func execute<Q: PFQueueType, P: Hashable where Q.Element.Position == P>(origin: P, inout queue: Q, findGold: (Q.Element) -> Bool, neighborsOf: (P) -> [P], explore: (P, Q.Element?, Q.Element?) -> Q.Element?) {
//        let origin = origin;
//        guard let oElement = explore(origin, nil, nil) else {return;}
//        queue.insert(oElement);
//        repeat {
//            guard let current = queue.popBest() else {break;}
//            let position = current.position;
//            
//            guard !findGold(current) else{return;}
//            let neighbors = neighborsOf(position);
//            neighbors.forEach{
//                let p = $0;
//                let visited = queue[p];
//                guard let ele = explore(p, current, visited) else {return;}
//                visited == nil ? queue.insert(ele) : queue.update(ele);
//            }
//        }while true
//    }
//    
//    //decompress path
//    func decompress<E: PathFinderElementType>(element: E) -> [E.Position]
//    {
//        var path: [E.Position] = [];
//        var ele = element;
//        repeat{
//            path.append(ele.position);
//            guard let parent = ele.parent as? E else{break;}
//            ele = parent;
//        }while true
//        return path.reverse();
//    }
//
//}

//MARK: == PathFindingType ==
public protocol PathFindingType {
    
    //element type
    typealias Element: PathFinderElementType;
    
    //request type
    typealias Request: PFRequestType;
    
    //search position; if return nil do nothing otherwise return element, visited == nil ? insert(element) : update(element)
    func explorePosition<S:PFDataSourceType where S.Position == Self.Element.Position>(position: Self.Element.Position, _ parent: Self.Element?, _ visited: Self.Element?, _ request: Self.Request, _ source: S) -> Self.Element?
}
extension PathFindingType{
    //decompress path
    func decompress(element: Self.Element) -> [Self.Element.Position]
    {
        var path: [Self.Element.Position] = [];
        var ele = element;
        repeat{
            path.append(ele.position);
            guard let parent = ele.parent as? Self.Element else{break;}
            ele = parent;
        }while true
        return path.reverse();
    }
}
extension PathFindingType where Self.Element.Position == Self.Request.Position {
    //execute
    func execute<Q: PFQueueType, S: PFDataSourceType where Q.Element == Self.Element, S.Position == Q.Element.Position>(request: Self.Request, inout queue: Q, source: S, @noescape findPath: ([Self.Element.Position]) -> ()) {
        let origin = request.origin;
        guard let oElement = self.explorePosition(origin, nil, nil, request, source) else {return;}
        queue.insert(oElement);
        var req = request;
        repeat {
            guard let current = queue.popBest() else {break;}
            let position = current.position;
            
            if let flag = req.findGoal(position) {
                let path = self.decompress(current);
                findPath(path);
                guard !flag else {return;}
            }
            
            let neighbors = source.neighborsOf(position);
            neighbors.forEach{
                let p = $0;
                let visited = queue[p];
                guard let ele = self.explorePosition(p, current, visited, req, source) else {return;}
                visited == nil ? queue.insert(ele) : queue.update(ele);
            }
        }while true
    }
}

//MARK: == PFQueueType ==
public protocol PFQueueType {
    //element type
    typealias Element: PathFinderElementType;
    
    //insert element and set element visited
    mutating func insert(element: Self.Element)
    
    //pop best element and set element closed
    mutating func popBest() -> Self.Element?
    
    //update element
    mutating func update(element: Self.Element)
    
    //return visited element at position
    subscript(position: Self.Element.Position) -> Self.Element?{get}
    
    //return all visited element record
    func getRecording() -> [Self.Element]
}

//MARK: == PFDataSourceType ==
public protocol PFDataSourceType {
    
    //position type
    typealias Position: Hashable;
    
    //return neighbors(passable) of position
    func neighborsOf(position: Self.Position) -> [Self.Position];
    
    //return cost between position and toPosition
    func costOf(position: Self.Position) -> CGFloat
    
    //return h value between position and goal
    func heuristicOf(position: Self.Position, _ toPosition: Self.Position) -> CGFloat
}

//MARK: == PFRequestType ==
public protocol PFRequestType {
    //position type
    typealias Position: Hashable;
    
    //origin position
    var origin: Self.Position{get}
    
    //if position is not goal return nil, otherwise if all goals was found return true else return false
    mutating func findGoal(position: Self.Position) -> Bool?
}

//MARK: == PFSingleGoalRequestType ==
public protocol PFSingleGoalRequestType: PFRequestType {
    //goal position
    var goal: Self.Position{get}
}
extension PFSingleGoalRequestType {
    public func findGoal(position: Self.Position) -> Bool? {
        guard goal == position else {return nil;}
        return true;
    }
}

//MARK: == PFMultiGoalRequestType ==
public protocol PFMultiGoalRequestType: PFRequestType {
    //goal position
    var goals: [Self.Position]{get set}
}
extension PFMultiGoalRequestType {
    public mutating func findGoal(position: Self.Position) -> Bool? {
        guard let i = self.goals.indexOf(position) else {return nil;}
        self.goals.removeAtIndex(i);
        return self.goals.isEmpty;
    }
}
