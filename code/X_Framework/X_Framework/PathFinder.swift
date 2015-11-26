//
//  PathFinder.swift
//  X_Framework
//
//  Created by xifanGame on 15/11/6.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation


//MARK: == PathFinderType ==
public protocol PathFinderType {
    //request type
    typealias Request: PFRequestType;
    
    //queue type
    typealias Queue: PFQueueType;
    
    //position type
    typealias Position: Hashable = Self.Queue.Element.Position;
    
    //create queue
    func queueGenerate() -> Self.Queue;
    
    //search position; if return nil do nothing otherwise return element, visited == nil ? insert(element) : update(element)
    func searchPosition(position: Self.Position, _ parent: Self.Queue.Element, _ visited: Self.Queue.Element?, _ request: Self.Request) -> Self.Queue.Element?
    
    //execute
    func execute(request req: Self.Request, @noescape findPath:([Self.Position]) -> (), _ completion: (([Self.Queue.Element]) -> ())?)
}
extension PathFinderType where Self.Request.Position == Self.Position, Self.Queue.Element.Position == Self.Position {
    
    //element type
    typealias Element = Self.Queue.Element;
    
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
    
    //execute
    public func execute<S:PFSourceType where S.Position == Self.Position>(request req: Self.Request, source: S, @noescape findPath: ([Self.Position]) -> ()) -> [Self.Queue.Element] {
        let originElement = Self.Queue.Element(g: 0, h: 0, position: req.origin, parent: nil);
        var request = req;
        var queue = self.queueGenerate();
        queue.insert(originElement);
        repeat{
            guard let current = queue.popBest() else {break;}
            let position = current.position;
            
            if let flag = request.findGoal(position) {
                let path = self.decompress(current);
                findPath(path);
                if flag {return queue.getRecording();}
            }
            
            let neighbors = source.neighborsOf(position);
            neighbors.forEach{
                let p = $0;
                let visited = queue[p];
                guard let ele = self.searchPosition(p, current, visited, request) else {return;}
                visited == nil ? queue.insert(ele) : queue.update(ele);
            }
        }while true
        return queue.getRecording();
    }
}

//MARK: == PFQueueType ==
public protocol PFQueueType {
    //element type
    typealias Element: PFElementType;
    
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

//MARK: == PFSourceType ==
public protocol PFSourceType {
    
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
    
    init(origin: Self.Position, goal: Self.Position)
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
    
    init(origin: Self.Position, goals:[Self.Position])
}
extension PFMultiGoalRequestType {
    public mutating func findGoal(position: Self.Position) -> Bool? {
        guard self.goals.count == 1 else {
            return self.goals[0] == position ? true : nil;
        }
        guard let i = self.goals.indexOf(position) else {return nil;}
        self.goals.removeAtIndex(i);
        return self.goals.isEmpty;
    }
}

//MARK: == PathFinderChainable ==
public protocol PFChainable
{
    //parent
    var parent: PFChainable?{get}
}

//MARK: == PathFinderElementType ==
public protocol PFElementType: PFChainable
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
    init(g: CGFloat, h:CGFloat, position: Self.Position, parent: PFChainable?)
    
    //set parent, g
    mutating func setParent(parent: PFChainable, g: CGFloat)
}

/*
next :
    request recode. var func
    CGFloat int, 
    tile break out(diagonal = false), 
    check neighbor passable
    multi start & multi goal
    ....
**/
