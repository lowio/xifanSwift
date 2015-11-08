//
//  PathFinder.swift
//  X_Framework
//
//  Created by 173 on 15/11/6.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//MARK: == PFinderChainable ==
public protocol PFinderChainable
{
    //parent
    var parent: PFinderChainable?{get}
}

//MARK: == PFinderPositional ==
public protocol PFinderPositional: PFinderChainable
{
    //Position type
    typealias Position: Hashable;
    
    //'self' is closed default false
    var isClosed:Bool{get set}
    
    //position
    var position: Self.Position{get}
    
    //init
    init(position: Self.Position, parent: PFinderChainable?)
    
    //set parent
    mutating func setParent(parent: PFinderChainable)
}

//MARK: == PFinderHPositional ==
public protocol PFinderHPositional: PFinderPositional
{
    //h score, hurisctic cost from 'self' point to goal point
    var h: CGFloat{get}
    
    //init
    init(h: CGFloat, position: Self.Position, parent: PFinderChainable?);
}

//MARK: == PFinderGPositional ==
public protocol PFinderGPositional: PFinderPositional
{
    //g score, real cost from start point to 'self' point
    var g: CGFloat{get}
    
    //init
    init(g: CGFloat, position: Self.Position, parent: PFinderChainable?);
    
    //set parent and g
    mutating func setParent(parent: PFinderChainable, g: CGFloat)
}

//MARK: == PFinderFPositional ==
public protocol PFinderFPositional: PFinderHPositional, PFinderGPositional
{
    //weight f = g + h
    var f:CGFloat{get}
    
    //init
    init(g: CGFloat, h:CGFloat, position: Self.Position, parent: PFinderChainable?)
}

//MARK: == PFinderProcessor ==
public protocol PFinderProcessor
{
    //element type
    typealias Element: PFinderPositional;
    
    //request type
    typealias Request: PFinderRequestType;
    
    //next best element
    mutating func popBest() -> Self.Element?
    
    //subscript get set
    subscript(position: Self.Element.Position) -> Self.Element?{get set}
    
    
    //is complete
    var isComplete:Bool{get}
    
    //position is goal
    mutating func isGoal(position: Self.Element.Position) -> Bool
    
    //return neighbors of position
    func neighborsOf(position: Self.Element.Position) -> [Self.Element.Position]
    
    //search position
    mutating func searchOf(position: Self.Element.Position, _ parent: Self.Element?) -> Self.Element?
    
    //find
    mutating func find(request: Self.Request, findOne: ([Self.Element.Position]) -> (), completion: (() -> ())?)
}
extension PFinderProcessor{
    //execute at start
    mutating func searching(origin: Self.Element.Position, findOne: ([Self.Element.Position]) -> (), completion: (() -> ())?){
        
        defer{
            completion?();
        }
        
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
            
            //find goal
            if self.isGoal(current.position) {
                let path = self.decompress(current);
                findOne(path);
                if self.isComplete {return;}
            }
            
            //explore neighbors
            let neighbors = self.neighborsOf(position);
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


//MARK: == PFinderRequestType ==
public protocol PFinderRequestType
{
    //position type
    typealias Position: Hashable;
    
    //return neighbors of position
    func neighborsOf(position: Self.Position) -> [Self.Position]
    
    //return cost
    func costBetween(position: Self.Position, and: Self.Position) -> CGFloat
    
    //return h value
    func heuristicOf(position: Self.Position, _ andPosition: Self.Position) -> CGFloat
    
    //start point
    var start: Self.Position{get}
}

//MARK: == PFinderSingleRequest ==
public protocol PFinderSingleRequest: PFinderRequestType
{
    var goal: Self.Position{get}
}

//MARK: == PFinderMultiRequest ==
public protocol PFinderMultiRequest: PFinderRequestType
{
    var goals: [Self.Position]{get}
}

//MARK: == PFinderElement ==
public struct PFinderElement<T: Hashable>
{
    //'self' is closed default false
    public var isClosed:Bool = false;
    
    //position
    public private (set) var position: T;
    
    //parent
    public private(set) var parent: PFinderChainable?
}
extension PFinderElement: PFinderPositional
{
    //init
    public init(position: T, parent: PFinderChainable?){
        self.position = position;
        self.parent = parent;
    }
    
    //set parent
    public mutating func setParent(parent: PFinderChainable)
    {
        self.parent = parent;
    }
}

//MARK: == PFinderGElement ==
public struct PFinderGElement<T: Hashable>
{
    //'self' is closed default false
    public var isClosed:Bool = false;
    
    //g;
    public private (set) var g: CGFloat = 0;
    
    //position
    public private (set) var position: T;
    
    //parent
    public private(set) var parent: PFinderChainable?
}
extension PFinderGElement: PFinderGPositional
{
    //init
    public init(position: T, parent: PFinderChainable?){
        self.position = position;
        self.parent = parent;
    }
    
    public init(g: CGFloat, position: T, parent: PFinderChainable?) {
        self.init(position: position, parent: parent);
        self.g = g;
    }
    
    //set parent
    public mutating func setParent(parent: PFinderChainable)
    {
        self.parent = parent;
    }
    
    public mutating func setParent(parent: PFinderChainable, g: CGFloat) {
        self.g = g;
        self.setParent(parent);
    }
}

//MARK: == PFinderHElement ==
public struct PFinderHElement<T: Hashable>
{
    //'self' is closed default false
    public var isClosed:Bool = false;
    
    //h;
    public private (set) var h: CGFloat = 0;
    
    //position
    public private (set) var position: T;
    
    //parent
    public private(set) var parent: PFinderChainable?
}
extension PFinderHElement: PFinderHPositional
{
    //init
    public init(position: T, parent: PFinderChainable?){
        self.position = position;
        self.parent = parent;
    }
    
    public init(h: CGFloat, position: T, parent: PFinderChainable?) {
        self.init(position: position, parent: parent);
        self.h = h;
    }
    
    //set parent
    public mutating func setParent(parent: PFinderChainable)
    {
        self.parent = parent;
    }
}

//MARK: == PFinderFElement ==
public struct PFinderFElement<T: Hashable>
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
extension PFinderFElement: PFinderFPositional
{
    //init
    public init(position: T, parent: PFinderChainable?){
        self.position = position;
        self.parent = parent;
        self.f = 0;
        self.g = 0;
        self.h = 0;
    }
    
    public init(g: CGFloat, position: T, parent: PFinderChainable?) {
        self.init(position: position, parent: parent);
        self.g = g;
        self.f = g;
    }
    
    public init(h: CGFloat, position: T, parent: PFinderChainable?) {
        self.init(position: position, parent: parent);
        self.h = h;
        self.f = h;
    }
    
    public init(g: CGFloat, h: CGFloat, position: T, parent: PFinderChainable?) {
        self.init(position: position, parent: parent);
        self.g = g;
        self.h = h;
        self.f = g + h;
    }
    
    //set parent
    public mutating func setParent(parent: PFinderChainable)
    {
        self.parent = parent;
    }
    
    public mutating func setParent(parent: PFinderChainable, g: CGFloat) {
        self.g = g;
        self.f = self.g + self.h;
        self.setParent(parent);
    }
}
