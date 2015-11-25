//
//  PathFinder.swift
//  X_Framework
//
//  Created by xifanGame on 15/11/6.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation


//MARK: == PathFinderRequestType ==
public protocol PathFinderRequestType {
    
    //position type
    typealias Position: Hashable;
    
    //return neighbors(passable) of position
    func neighborsOf(position: Self.Position) -> [Self.Position];
    
    //return cost between position and toPosition
    func costOf(position: Self.Position, _ toPosition: Self.Position) -> CGFloat
    
    //return h value between position and goal
    func heuristicOf(position: Self.Position) -> CGFloat
    
    //origin position
    var origin: Self.Position?{get}
    
    //is complete
    var isComplete: Bool{get}
    
    //postion is target?
    mutating func findTarget(position: Self.Position) -> Bool
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
    
    //search position; if return nil do nothing otherwise return element, visited == nil ? insert(element) : update(element)
    func searchPosition(position: Self.Position, _ parent: Self.Queue.Element?, _ visited: Self.Queue.Element?, _ request: Self.Request) -> Self.Queue.Element?
    
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
    public func execute(request req: Self.Request, @noescape findPath: ([Self.Position]) -> (), _ completion: (([Self.Queue.Element]) -> ())? = nil) {
        guard let origin = req.origin else {return;}
        guard let originElement = self.searchPosition(origin, nil, nil, req) else {return;}
        var request = req;
        var queue = self.queueGenerate();
        queue.insert(originElement);
        repeat{
            guard let current = queue.popBest() else {break;}
            let position = current.position;
            
            if request.findTarget(position) {
                let path = self.decompress(current);
                findPath(path);
                if request.isComplete {
                    completion?(queue.allVisitedList());
                    break;
                }
            }
            
            let neighbors = request.neighborsOf(position);
            neighbors.forEach{
                let p = $0;
                let visited = queue[p];
                guard let ele = self.searchPosition(p, current, visited, request) else {return;}
                visited == nil ? queue.insert(ele) : queue.update(ele);
            }
        }while true
    }
}

//MARK: == PathFinderQueueType ==
public protocol PathFinderQueueType {
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
    
    //return all visited element
    func allVisitedList() -> [Self.Element]
}

//MARK: == PathFinderChainable ==
public protocol PathFinderChainable
{
    //parent
    var parent: PathFinderChainable?{get}
}

//MARK: == PathFinderElementType ==
public protocol PathFinderElementType: PathFinderChainable
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
    init(g: CGFloat, h:CGFloat, position: Self.Position, parent: PathFinderChainable?)
    
    //set parent, g
    mutating func setParent(parent: PathFinderChainable, g: CGFloat)
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
