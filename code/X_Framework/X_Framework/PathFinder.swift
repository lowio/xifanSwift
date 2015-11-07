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

//MARK: == PathPositionElement ==
public protocol PathPositionElementType: PathChainable
{
    //Position type
    typealias Position: Hashable;
    
    //'self' is closed default false
    var isClosed:Bool{get set}
    
    //position
    var position: Self.Position{get}
    
    //init
    init(position: Self.Position, parent: PathChainable?)
    
    //set parent
    mutating func setParent(parent: PathChainable)
}

//MARK: == PathHElementType ==
public protocol PathHElementType: PathPositionElementType
{
    //h score, hurisctic cost from 'self' point to goal point
    var h: CGFloat{get}
    
    //init
    init(h: CGFloat, position: Self.Position, parent: PathChainable?);
}

//MARK: == PathGElementType ==
public protocol PathGElementType: PathPositionElementType
{
    //g score, real cost from start point to 'self' point
    var g: CGFloat{get}
    
    //init
    init(g: CGFloat, position: Self.Position, parent: PathChainable?);
    
    //set parent and g
    mutating func setParent(parent: PathChainable, g: CGFloat)
}

//MARK: == PathFElementType ==
public protocol PathFElementType: PathHElementType, PathGElementType
{
    //weight f = g + h
    var f:CGFloat{get}
    
    //init
    init(g: CGFloat, h:CGFloat, position: Self.Position, parent: PathChainable?)
}

//MARK: == PFElementGreneratorType ==
public protocol PFElementGreneratorType: GeneratorType
{
    //element type
    typealias Element: PathPositionElementType;
    
    //next best element
    mutating func next() -> Self.Element?
    
    //if contains element at position return it, otherwise return nil
    subscript(position: Self.Element.Position) -> Self.Element?{get set}
}

//MARK: == PathFinderProcessorType ==
public protocol PathFinderProcessorType
{
    //element generator
    typealias Element: PathPositionElementType;
    
    //return element
    mutating func getElementBy<R: PathFinderRequest where R.Position == Self.Element.Position>(position: Self.Element.Position, _ request: R, _ chainFrom: Self.Element?) -> Self.Element?
    
    //execute
    mutating func execute<R: PathFinderRequest where R.Position == Self.Element.Position>(request: R, success: ([Self.Element.Position])->())
}
extension PathFinderProcessorType
{
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

extension PathFinderProcessorType
{
    //execute
    mutating func execute<G: PFElementGreneratorType, R: PathFinderRequest where G.Element == Self.Element, R.Position == Self.Element.Position>(request: R, openList o: G, success: ([Self.Element.Position])->()){
        
        var req = request;
        guard let start = request.start else {return;}
        var openList = o;
        guard let se = self.getElementBy(start, req, nil) else{return;}
        var current = se;
        openList[start] = current;
        
        //repeat
        repeat{
            guard let _next = openList.next() else {break;}
            current = _next;
            let position = current.position;
            
            current.isClosed = true;
            openList[position] = current;
            
            //find goal
            if req.findGoal(current.position) {
                let path = self.decompress(current);
                success(path);
                if req.isComplete {return;}
            }
            
            //explore neighbors
            let neighbors = req.neighborsOf(position);
            neighbors.forEach{
                let n = $0;
                guard let element = self.getElementBy(n, req, current) else {return;}
                openList[element.position] = element;
            }
        }while true
    }
}

//MARK: == PathFinderRequest ==
public protocol PathFinderRequest
{
    //position type
    typealias Position: Hashable;
    
    //start position
    var start: Self.Position?{get}
    
    //return neighbors of position
    func neighborsOf(position: Self.Position) -> [Self.Position]
    
    //return cost
    func costBetween(position: Self.Position, and: Self.Position) -> CGFloat
    
    //return h value
    func heuristicOf(position: Self.Position) -> CGFloat
    
    //is complete
    var isComplete: Bool{get}
    
    //find goal
    mutating func findGoal(element: Self.Position) -> Bool
}

//MARK: == PathSingleRequest ==
public protocol PathSingleRequest: PathFinderRequest
{
    var goal: Self.Position{get}
    var isComplete: Bool{get set}
}
extension PathSingleRequest
{
    public mutating func findGoal(element: Self.Position) -> Bool {
        guard goal == element else {return false;}
        self.isComplete = true;
        return true;
    }
}


//MARK: == PathPositionElement ==
public struct PathPositionElement<T: Hashable>
{
    //'self' is closed default false
    public var isClosed:Bool = false;
    
    //position
    public private (set) var position: T;
    
    //parent
    public private(set) var parent: PathChainable?
}
extension PathPositionElement: PathPositionElementType
{
    //init
    public init(position: T, parent: PathChainable?){
        self.position = position;
        self.parent = parent;
    }
    
    //set parent
    public mutating func setParent(parent: PathChainable)
    {
        self.parent = parent;
    }
}

//MARK: == PathGElement ==
public struct PathGElement<T: Hashable>
{
    //'self' is closed default false
    public var isClosed:Bool = false;
    
    //g;
    public private (set) var g: CGFloat = 0;
    
    //position
    public private (set) var position: T;
    
    //parent
    public private(set) var parent: PathChainable?
}
extension PathGElement: PathGElementType
{
    //init
    public init(position: T, parent: PathChainable?){
        self.position = position;
        self.parent = parent;
    }
    
    public init(g: CGFloat, position: T, parent: PathChainable?) {
        self.init(position: position, parent: parent);
        self.g = g;
    }
    
    //set parent
    public mutating func setParent(parent: PathChainable)
    {
        self.parent = parent;
    }
    
    public mutating func setParent(parent: PathChainable, g: CGFloat) {
        self.g = g;
        self.setParent(parent);
    }
}

//MARK: == PathHElement ==
public struct PathHElement<T: Hashable>
{
    //'self' is closed default false
    public var isClosed:Bool = false;
    
    //h;
    public private (set) var h: CGFloat = 0;
    
    //position
    public private (set) var position: T;
    
    //parent
    public private(set) var parent: PathChainable?
}
extension PathHElement: PathHElementType
{
    //init
    public init(position: T, parent: PathChainable?){
        self.position = position;
        self.parent = parent;
    }
    
    public init(h: CGFloat, position: T, parent: PathChainable?) {
        self.init(position: position, parent: parent);
        self.h = h;
    }
    
    //set parent
    public mutating func setParent(parent: PathChainable)
    {
        self.parent = parent;
    }
}



//MARK: == PathFElement ==
public struct PathFElement<T: Hashable>
{
    //'self' is closed default false
    public var isClosed:Bool = false;
    
    //g, h;
    public private (set) var g, h, f: CGFloat;
    
    //position
    public private (set) var position: T;
    
    //parent
    public private(set) var parent: PathChainable?
}
extension PathFElement: PathFElementType
{
    //init
    public init(position: T, parent: PathChainable?){
        self.position = position;
        self.parent = parent;
        self.f = 0;
        self.g = 0;
        self.h = 0;
    }
    
    public init(g: CGFloat, position: T, parent: PathChainable?) {
        self.init(position: position, parent: parent);
        self.g = g;
        self.f = g;
    }
    
    public init(h: CGFloat, position: T, parent: PathChainable?) {
        self.init(position: position, parent: parent);
        self.h = h;
        self.f = h;
    }
    
    public init(g: CGFloat, h: CGFloat, position: T, parent: PathChainable?) {
        self.init(position: position, parent: parent);
        self.g = g;
        self.h = h;
        self.f = g + h;
    }
    
    //set parent
    public mutating func setParent(parent: PathChainable)
    {
        self.parent = parent;
    }
    
    public mutating func setParent(parent: PathChainable, g: CGFloat) {
        self.g = g;
        self.f = self.g + self.h;
        self.setParent(parent);
    }
}
