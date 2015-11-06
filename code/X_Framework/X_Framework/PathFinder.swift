//
//  PathFinder.swift
//  X_Framework
//
//  Created by 173 on 15/11/6.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//MARK: == PathChainable ==
public protocol PathChainable
{
    //parent
    var parent: PathChainable?{get}
}

//MARK: == PathMarkable ==
public protocol PathMarkable: PathChainable
{
    //Position type
    typealias Position: Hashable;
    
    //'self' is closed default false
    var isClosed:Bool{get set}
    
    //g score, real cost from start point to 'self' point
    var g: CGFloat{get}
    
    //h score, hurisctic cost from 'self' point to goal point
    var h: CGFloat{get}
    
    //weight f = g + h
    var f:CGFloat{get}
    
    //position
    var position: Self.Position{get}
    
    //set parent
    mutating func setParent(parent: Self, g: CGFloat)
    
    //init
    init(g: CGFloat, h:CGFloat, position: Self.Position, parent: FinderChainable?)
}

//MARK: == PathOpenListType ==
public protocol PathOpenListType: GeneratorType
{
    //element type
    typealias Element: PathMarkable;
    
    //insert element
    mutating func insert(element: Self.Element)
    
    //next best element
    mutating func next() -> Self.Element?
    
    //update element
    mutating func update(element: Self.Element)
    
    //close element
    mutating func close(element: Self.Element)
    
    //if contains element at position return it, otherwise return nil
    subscript(position: Self.Element.Position) -> Self.Element?{get}
}

//MARK: == PathFinderEmployer ==
public protocol PathFinderEmployer
{
    //position type
    typealias Position;
    
    //return neighbors around position
    func neighborsOf(position: Self.Position) -> [Self.Position]
    
    //return cost between position and p, if ignore cost return 0;
    func costBetween(position: Self.Position, and p: Self.Position) -> CGFloat
    
    //return h between position and p, if ignore direction return 0;
    func heuristicBetween(position: Self.Position, and p: Self.Position) -> CGFloat
}

//MARK: == PathFinderProcessorType ==
public protocol PathFinderProcessorType
{
    //path open list type
    typealias OpenList: PathOpenListType;
    
    //start
    var start: Self.OpenList.Element.Position{get set}
    
    //get neighbors
    var neighborsOf: (Self.OpenList.Element.Position) -> [Self.OpenList.Element.Position]{get set}
    
    //return cost between $0 and $1, if ignore cost return 0;
    var costBetween: (Self.OpenList.Element.Position, Self.OpenList.Element.Position) -> CGFloat{get set}
    
    //return h between $0 and $1, if ignore direction return 0;
    var heuristicBetween: (Self.OpenList.Element.Position, Self.OpenList.Element.Position) -> CGFloat{get set}
    
    //generate open list
    func generateOpenList() -> Self.OpenList;
    
    //generate element
    func generateElement(position: Self.OpenList.Element.Position, _ chainFrom: Self.OpenList.Element?) -> Self.OpenList.Element
    
    //find goal
    mutating func findGoal(element: Self.OpenList.Element) -> Bool
    
    //is complete
    var isComplete: Bool{get}
    
    //execute
    mutating func execute<E: PathFinderEmployer where E.Position == Self.OpenList.Element.Position>(employer: E, success: ([E.Position]) -> ())
}
extension PathFinderProcessorType
{
    //decompress path
    func decompress(element: Self.OpenList.Element) -> [Self.OpenList.Element.Position]
    {
        var path: [Self.OpenList.Element.Position] = [];
        var ele = element;
        repeat{
            path.append(ele.position);
            guard let parent = ele.parent as? Self.OpenList.Element else{break;}
            ele = parent;
        }while true
        return path.reverse();
    }
    
    //execute
    mutating func execute(success: ([Self.OpenList.Element.Position])->()){
        //open list
        var openList = self.generateOpenList();
        
        //start element
        var current = self.generateElement(start, nil);
        openList.insert(current);
        
        //repeat
        repeat{
            guard let _next = openList.next() else {break;}
            current = _next;
            let position = current.position;
            
            current.isClosed = true;
            openList.close(current);
            
            //find goal
            if findGoal(current) {
                let path = self.decompress(current);
                success(path);
                if isComplete {return;}
            }
            
            //explore neighbors
            let neighbors = self.neighborsOf(position);
            neighbors.forEach{
                let n = $0;
//                let cost = self.costBetween(position, n);
//                let g = current.g + cost;
//                guard let visited = openList[n] else{
//                    let ele = self.generateElement(n, current);
//                    openList.insert(ele);
//                    return;
//                }
//                guard !visited.isClosed && cost != 0 && g < visited.g else{return;}
//                var ele = visited;
//                ele.setParent(current, g: g);
//                openList.update(ele);
            }
        }while true
    }
}

//MARK: == PFinderSingleProcessor ==
public protocol PFinderSingleProcessor: PathFinderProcessorType
{
    //goal
    var goal: Self.OpenList.Element.Position{get set}
    
    //is complete
    var isComplete: Bool {get set}
}
extension PFinderSingleProcessor
{
    mutating public func findGoal(element: Self.OpenList.Element) -> Bool {
        guard element.position == self.goal else {return false;}
        self.isComplete = true;
        return true;
    }
}

//MARK: == PFinderMultiProcessor ==
public protocol PFinderMultiProcessor: PathFinderProcessorType
{
    //goal
    var goals: [Self.OpenList.Element.Position]{get set}
    
    //is complete
    var isComplete: Bool {get}
}
extension PFinderMultiProcessor
{
    mutating public func findGoal(element: Self.OpenList.Element) -> Bool {
        guard let i = (self.goals.indexOf{element.position == $0}) else {return false;}
        self.goals.removeAtIndex(i);
        return true;
    }
    
    //is complete
    public var isComplete: Bool {return self.goals.isEmpty;}
}

//MARK: == PFGreedyBestFirst ==
public protocol PFGreedyBestFirst: PFinderSingleProcessor{}
extension PFGreedyBestFirst
{
    public mutating func execute<E : PathFinderEmployer where E.Position == Self.OpenList.Element.Position>(employer: E, success: ([E.Position]) -> ()) {
//        self.start = employer.start;
        //set start
        //set goal
        self.neighborsOf = employer.neighborsOf;
        self.heuristicBetween = employer.heuristicBetween;
        self.execute(success);
    }
    
    //return cost between $0 and $1, if ignore cost return 0;
    public var costBetween: (Self.OpenList.Element.Position, Self.OpenList.Element.Position) -> CGFloat{return {
        (a:Self.OpenList.Element.Position, b:Self.OpenList.Element.Position)
        in
        return 0;
    };}
}




//next: 
/**
    1. do neighbor
    2. protocol: Dijkstra, GreedyBestFirst, AstarFinder, BreadthFirst
*/















