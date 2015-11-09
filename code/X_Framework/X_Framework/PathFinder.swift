//
//  PathFinder.swift
//  X_Framework
//
//  Created by 173 on 15/11/6.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation



//MARK: == PFinderProcessor ==
public protocol PFinderProcessor
{
    //element type
    typealias Element: PFinderElementType;
    
    //data source type
    typealias DataSource: PFinderDataSource;
    
    //data source
    var dataSource: Self.DataSource{get}
    
    //next best element
    mutating func popBest() -> Self.Element?
    
    //subscript get set
    subscript(position: Self.Element.Position) -> Self.Element?{get set}
    
    //search position
    mutating func searchOf(position: Self.Element.Position, _ parent: Self.Element?) -> Self.Element?
    
    //preparation
    mutating func preparation(start: Self.Element.Position, goal: Self.Element.Position)
}
extension PFinderProcessor where Self.DataSource.Position == Self.Element.Position{
    //search
    public mutating func searching(start: Self.Element.Position, goal: Self.Element.Position, completion: ([Self.Element.Position]) -> ()){
        self.preparation(start, goal: goal);
        self.processing(start){
            let element = $0;
            guard goal == element.position else {return false;}
            let path = self.decompress(element);
            completion(path);
            return true
        }
    }
    
    //search
    mutating func processing(origin: Self.Element.Position, @noescape termination: (Self.Element) -> Bool){
        guard let originElement = self.searchOf(origin, nil) else{return;}
        var current = originElement;
        self[current.position] = current;
        
        //repeat
        repeat{
            guard let _next = self.popBest() else {break;}
            current = _next;
            let position = current.position;
            
            current.isClosed = true;
            self[position] = current;
            
            guard !termination(current) else {return;}
            
            //explore neighbors
            let neighbors = self.dataSource.neighborsOf(position);
            neighbors.forEach{
                let n = $0;
                guard let element = self.searchOf(n, current) else {return;}
                self[element.position] = element;
            }
        }while true
    }
    
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

public protocol PFinderMultiProcessor: PFinderProcessor{}
extension PFinderMultiProcessor where Self.DataSource.Position == Self.Element.Position{
    //search
    public mutating func searching(start: Self.Element.Position, goals gs: [Self.Element.Position], findGoal: ([Self.Element.Position]) -> (), completion: (() -> ())? = nil){
        guard !gs.isEmpty else {
            completion?();
            return;
        }
        
        let first = gs[0];
        guard gs.count > 1 else{
            self.searching(start, goal: first){
                findGoal($0);
                completion?();
            }
            return;
        }
        
        self.preparation(start, goal: first)
        var goals = gs;
        self.processing(start){
            let position = $0.position;
            guard let i = goals.indexOf(position) else {return false;}
            let path = self.decompress($0);
            findGoal(path);
            goals.removeAtIndex(i);
            guard goals.isEmpty else{return false;}
            completion?();
            return true;
        }
    }
}

//MARK: == PFinderDataSource ==
public protocol PFinderDataSource
{
    //position type
    typealias Position: Hashable;
    
    //return neighbors of position
    func neighborsOf(position: Self.Position) -> [Self.Position]
    
    //return cost
    func costBetween(position: Self.Position, and: Self.Position) -> CGFloat
    
    //return h value
    func heuristicOf(position: Self.Position, _ andPosition: Self.Position) -> CGFloat
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
        self.parent = parent;
    }
}
