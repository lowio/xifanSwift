//
//  PathFinder.swift
//  X_Framework
//
//  Created by xifanGame on 15/11/6.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//MARK: == PathFinderQueueType ==
public protocol PathFinderQueueType {
    //element type
    typealias Element: PFinderElementType;
    
    //insert element and set element visited
    mutating func insert(element: Self.Element)
    
    //pop best element and set element closed
    mutating func popBest() -> Self.Element?
    
    //return visited element at position
    subscript(position: Self.Element.Position) -> Self.Element?{get}
}

//MARK: == PathFinderRequestType ==
public protocol PathFinderRequestType {
    
    //position type
    typealias Position: Hashable;
    
    //return neighbors(passable) of position
    func neighborsOf(position: Self.Position) -> [Self.Position];
    
    //return cost between position and toPosition
    func costOf(position: Self.Position, _ toPosition: Self.Position) -> CGFloat
    
    //return h value between position and toPosition
    func heuristicOf(position: Self.Position, _ toPosition: Self.Position) -> CGFloat
}

//MARK: == PathFinderType ==
public protocol PathFinderType {
    //request type
    typealias Request: PathFinderRequestType;
    
    //queue type
    typealias Queue: PathFinderQueueType;
    
    //position type
    typealias Position: Hashable = Self.Queue.Element.Position;
    
    //create queue
    func queueGenerate() -> Self.Queue;
    
    //search position
    func searchPosition(position: Self.Position, _ goal: Self.Position, _ parent: Self.Queue.Element?, _ request: Self.Request, inout _ queue: Self.Queue)
    
    //execute single goal
    func execute(start: Self.Position, goal: Self.Position, request: Self.Request, completion: ([Self.Position]) -> ())
}
extension PathFinderType where Self.Request.Position == Self.Position, Self.Queue.Element.Position == Self.Position {
    
    //element type
    typealias Element = Self.Queue.Element;
    
    //search
    func doSearching(origin: Self.Position, _ goal: Self.Position, request: Self.Request, @noescape _ termination: (Element) -> Bool){
        var queue = self.queueGenerate();
        self.searchPosition(origin, goal, nil, request, &queue);
        repeat{
            guard let current = queue.popBest() else {break;}
            let position = current.position;
            guard !termination(current) else {return;}
            let neighbors = request.neighborsOf(position);
            neighbors.forEach{
                self.searchPosition($0, goal, current, request, &queue);
            }
        }while true
    }
    
    //decompress path
    func decompress(element: Element) -> [Self.Position]
    {
        var path: [Self.Position] = [];
        var ele = element;
        repeat{
            path.append(ele.position);
            guard let parent = ele.parent as? Element else{break;}
            ele = parent;
        }while true
        return path.reverse();
    }
    
    //execute single goal
    public func execute(start: Self.Position, goal: Self.Position, request: Self.Request, completion: ([Self.Position]) -> ()) {
        self.doSearching(start, goal, request: request){
            let element = $0;
            guard goal == element.position else {return false;}
            let path = self.decompress(element);
            completion(path);
            return true
        }
    }
}

//MARK: == PathFinderMultiType ==
public protocol PathFinderMultiType: PathFinderType {
    //execute multi goal
    func execute(start: Self.Position, goals gs: [Self.Position], request: Self.Request, findGoal: ([Self.Position]) -> (), completion: () -> ())
}
extension PathFinderMultiType  where Self.Request.Position == Self.Position, Self.Queue.Element.Position == Self.Position {
    //execute multi goal
    public func execute(start: Self.Position, goals gs: [Self.Position], request: Self.Request, findGoal: ([Self.Position]) -> (), completion: () -> ()) {
        guard !gs.isEmpty else {
            completion();
            return;
        }
        let goal = gs[0];
        guard gs.count > 1 else{
            self.execute(start, goal: goal, request: request){
                findGoal($0);
                completion();
            }
            return;
        }
        
        var goals = gs;
        self.doSearching(start, goal, request: request){
            guard let i = goals.indexOf($0.position) else {return false;}
            goals.removeAtIndex(i);
            let path = self.decompress($0);
            findGoal(path);
            guard goals.isEmpty else {return false;}
            completion();
            return true;
        }
    }
}

//MARK: == PFinderChainable ==
public protocol PFinderChainable
{
    //parent
    var parent: PFinderChainable?{get}
}

//MARK: == PFinderElementType ==
public protocol PFinderElementType: PFinderChainable
{
    //Position type
    typealias Position: Hashable;
    
    //'self' is closed default false
    var isClosed:Bool{get set}
    
    //h score, hurisctic cost from 'self' point to goal point
    var h: CGFloat{get}
    
    //g score, real cost from start point to 'self' point
    var g: CGFloat{get}
    
    //weight f = g + h
    var f:CGFloat{get}
    
    //position
    var position: Self.Position{get}
    
    //init
    init(g: CGFloat, h:CGFloat, position: Self.Position, parent: PFinderChainable?)
    
    //set parent, g
    mutating func setParent(parent: PFinderChainable, g: CGFloat)
}

//MARK: == PFinderElement ==
public struct PFinderElement<T: Hashable>
{
    //'self' is closed default false
    public var isClosed:Bool = false;
    
    //g, h;
    public private (set) var g, h, f: CGFloat;
    
    //position
    public private (set) var position: T;
    
    //parent
    public private(set) var parent: PFinderChainable?
}
extension PFinderElement: PFinderElementType
{
    public init(g: CGFloat, h: CGFloat, position: T, parent: PFinderChainable?) {
        self.g = g;
        self.h = h;
        self.f = g + h;
        self.position = position;
        self.parent = parent;
    }
    
    public mutating func setParent(parent: PFinderChainable, g: CGFloat) {
        self.g = g;
        self.f = self.g + self.h;
        self.parent = parent;
    }
}



//next : break out ....
