//
//  Finder.swift
//  X_Framework
//
//  Created by 173 on 15/12/2.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//MARK: == FinderElementType ==
public protocol FinderElementType {
    //point type
    typealias Point: Hashable;
    
    //point
    var point: Point {get}
    
    //parent
    var parent: Any? {get}
    
    //f value
    var f: Int{get}
    
    //is closed
    var isClosed: Bool{get set}
    
    //update
    mutating func update(f: Int, parent: Self)
}

//MARK: == FinderDataSource ==
public protocol FinderDataSourceType {
    
    //point type
    typealias Point;
    
    //return neighbors of point
    func neighborsOf(point: Point) -> [Point];
    
    ///return cost from f point to t point if it is passable
    ///otherwise return nil
    func getCost(from f: Point, to t: Point) -> Int?
}

//MARK: == FinderElementBuilding ==
public protocol FinderElementBuilding {
    
    ///element type
    typealias Element: FinderElementType;
    
    ///build element
    func buildElement(cost c: Int, from parent: Element?, to point: Element.Point, inVisited: Element?) -> Element?
}

//MARK: == _FinderDelegateType ==
public protocol _FinderDelegateType:GeneratorType {
    
    /// finder element type
    typealias Element: FinderElementType;
    
    ///insert element and set element visited
    mutating func insert(element: Element)

    ///update and reorder element
    mutating func updateAndReorder(element: Element)
    
    ///update element
    mutating func updateNoReorder(element: Element)
    
    ///return next examing element
    ///- Requires: close the return element
    mutating func next() -> Element?

    ///return visited element at point
    subscript(point: Element.Point) -> Element?{get}
    
    ///return track array
    func backtrace(element: Element) -> [Element.Point]
    
    ///trace visited record
    func backtraceRecord() -> [Element]
}

//MARK: == _FinderProcessorType ==
public protocol _FinderProcessorType {
    //source type
    typealias Source: FinderDataSourceType;
    
    //delegate type
    typealias Delegate: _FinderDelegateType;
    
    //finder type
    typealias Building: FinderElementBuilding;
}
extension _FinderProcessorType
where
Self.Source.Point == Self.Building.Element.Point,
Self.Delegate.Element == Self.Building.Element {
    
    //point type
    typealias Point = Building.Element.Point;
    
    ///Return track array from origin to goal
    @warn_unused_result
    static public func execute(from origin: Point, to goal: Point, delegate: Delegate, builder: Building, source: Source) -> [Point: [Point]]{
        return Self.execute(delegate, origin: origin, builder: builder, source: source){
            guard $0 == goal else {return nil;}
            return true;
        };
    }
    
    ///Return track dictionary from origin to goals
    @warn_unused_result
    static public func execute(inout from points: [Point], to goal: Point, delegate: Delegate, builder: Building, source: Source) -> [Point: [Point]]{
        guard points.count > 1 else{
            return Self.execute(from: goal, to: points[0], delegate: delegate, builder: builder, source: source)
        }
        
        return Self.execute(delegate, origin: goal, builder: builder, source: source){
            guard let i = points.indexOf($0) else {return nil;}
            points.removeAtIndex(i);
            return points.isEmpty;
        };
    }
    
    ///Return track dictionary
    /// - Requires: isTerminal return nil if $0 is not a goal, otherwise if all goal was found return ture else return false
    @warn_unused_result
    static public func execute(var delegate: Delegate, origin: Point, builder: Building, source: Source,
        @noescape _ isTerminal: (Point) -> Bool?) -> [Point: [Point]] {
        guard let origin = builder.buildElement(cost: 0, from: .None, to: origin, inVisited: .None) else {return [:];}
        delegate.insert(origin);
        var paths:[Point: [Point]] = [:];
        repeat{
            guard var element = delegate.next() else{break;}
            element.isClosed = true;
            delegate.updateNoReorder(element);
            let point = element.point;
            if let flag = isTerminal(point){
                let path = delegate.backtrace(element);
                paths[point] = path;
                guard !flag else{break;}
            }
            let neighbors = source.neighborsOf(element.point);
            neighbors.forEach{
                let p = $0;
                guard let cost = source.getCost(from: point, to: p) else {return;}
                guard let visited = delegate[p] else{
                    guard let ele = builder.buildElement(cost: cost, from: element, to: p, inVisited: .None) else{return;}
                    delegate.insert(ele);
                    return;
                }
                guard !visited.isClosed else {return;}
                guard let ele = builder.buildElement(cost: cost, from: element, to: p, inVisited: visited)else{return;}
                delegate.updateAndReorder(ele);
                print("WARN: _FinderProcessorType.execute - delegate.reorder =================");
            }
        }while true
        return paths;
    }
}

//MARK: == _FinderProcessor ==
public struct _FinderProcessor {
    ///Return track array from origin to goal
    @warn_unused_result
    static public func execute<
        Point,
        Source: FinderDataSourceType,
        Delegate: _FinderDelegateType,
        Building: FinderElementBuilding
        where
        Point == Source.Point,
        Source.Point == Building.Element.Point,
        Delegate.Element == Building.Element
    >(from origin: Point, to goal: Point, delegate: Delegate, builder: Building, source: Source) -> [Point: [Point]]{
        return _FinderProcessor.execute(delegate, origin: origin, builder: builder, source: source){
            guard $0 == goal else {return nil;}
            return true;
        };
    }
    
    ///Return track dictionary from origin to goals
    @warn_unused_result
    static public func execute<
        Point,
        Source: FinderDataSourceType,
        Delegate: _FinderDelegateType,
        Building: FinderElementBuilding
        where
        Point == Source.Point,
        Source.Point == Building.Element.Point,
        Delegate.Element == Building.Element
    >(inout from points: [Point], to goal: Point, delegate: Delegate, builder: Building, source: Source) -> [Point: [Point]]{
        guard points.count > 1 else{
            return _FinderProcessor.execute(from: goal, to: points[0], delegate: delegate, builder: builder, source: source)
        }
        
        return _FinderProcessor.execute(delegate, origin: goal, builder: builder, source: source){
            guard let i = points.indexOf($0) else {return nil;}
            points.removeAtIndex(i);
            return points.isEmpty;
        };
    }
    
    ///Return track dictionary
    /// - Requires: isTerminal return nil if $0 is not a goal, otherwise if all goal was found return ture else return false
    @warn_unused_result
    static public func execute<
        Point,
        Source: FinderDataSourceType,
        Delegate: _FinderDelegateType,
        Building: FinderElementBuilding
        where
        Point == Source.Point,
        Source.Point == Building.Element.Point,
        Delegate.Element == Building.Element
    >(var delegate: Delegate, origin: Point, builder: Building, source: Source,
        @noescape _ isTerminal: (Point) -> Bool?) -> [Point: [Point]] {
            guard let origin = builder.buildElement(cost: 0, from: .None, to: origin, inVisited: .None) else {return [:];}
            delegate.insert(origin);
            var paths:[Point: [Point]] = [:];
            repeat{
                guard var element = delegate.next() else{break;}
                element.isClosed = true;
                delegate.updateNoReorder(element);
                let point = element.point;
                if let flag = isTerminal(point){
                    let path = delegate.backtrace(element);
                    paths[point] = path;
                    guard !flag else{break;}
                }
                let neighbors = source.neighborsOf(element.point);
                neighbors.forEach{
                    let p = $0;
                    guard let cost = source.getCost(from: point, to: p) else {return;}
                    guard let visited = delegate[p] else{
                        guard let ele = builder.buildElement(cost: cost, from: element, to: p, inVisited: .None) else{return;}
                        delegate.insert(ele);
                        return;
                    }
                    guard !visited.isClosed else {return;}
                    guard let ele = builder.buildElement(cost: cost, from: element, to: p, inVisited: visited)else{return;}
                    delegate.updateAndReorder(ele);
                    print("WARN: _FinderProcessorType.execute - delegate.reorder =================");
                }
            }while true
            return paths;
    }
}


//MARK: == FinderDelegate ==
struct FinderDelegate<Element: FinderElementType>{

    //open list
    private(set) var openList: PriorityQueue<Element>;

    //visite list
    private(set) var visiteList: [Element.Point: Element];

}
extension FinderDelegate {
    //init
    init(){
        self.openList = PriorityQueue{
            return $0.f < $1.f
        }
        self.visiteList = [:];
    }
    
    ///insert element and set element visited
    mutating func insert(element: Element){
        self.openList.insert(element);
        self.visiteList[element.point] = element;
    }
    
    ///update and reorder element
    mutating func updateAndReorder(element: Element){
        guard let i = (self.openList.indexOf{$0.point == element.point}) else {return;}
        self.openList.replaceElement(element, atIndex: i);
        self.visiteList[element.point] = element;
    }
    
    ///update element
    mutating func updateNoReorder(element: Element) {
        self.visiteList[element.point] = element;
    }
    
    ///return visited element at point
    subscript(point: Element.Point) -> Element? {
        return self.visiteList[point];
    }
}
extension FinderDelegate: _FinderDelegateType{
    ///pop best element and set element closed
    mutating func next() -> Element?{
        return self.openList.popBest();
    }
    
    ///return track array
    func backtrace(element: Element) -> [Element.Point]{
        var ele = element;
        var path = [ele.point];
        repeat{
            guard let p = ele.parent as? Element else {break;}
            ele = p;
            path.append(ele.point);
        }while true
        return path;
    }
    
    ///trace visited record
    func backtraceRecord() -> [Element]{
        return self.visiteList.values.reverse();
    }
}


//MARK: == FinderElement ==
public struct FinderElement<P: Hashable> {
    
    //point
    public private(set) var point: P;
    
    //parent
    public private(set) var parent: Any?
    
    //f valuep
    public private(set) var f: Int;
    
    //is closed
    public var isClosed: Bool = false;
    
    //init
    public init(point: P, f: Int, parent: Any?){
        self.point = point;
        self.f = f;
        self.parent = parent;
    }
}
extension FinderElement: FinderElementType {
    public mutating func update(f: Int, parent: FinderElement) {
        self.f = f;
        self.parent = parent;
    }
}


public protocol FinderHeuristicType{
    typealias Point: Hashable;
    
    //heristic h value
    static func heuristic(from f: Point, to t: Point) -> Int
}

//MARK: == GreedyBestFinder ==
public struct GreedyBestFinder<S: FinderDataSourceType, H: FinderHeuristicType where S.Point == H.Point>{
    //delegate
    private var delegate: FinderDelegate<Element>!;
    
    //get h
    private var getH: ((S.Point) -> Int)!
}
extension GreedyBestFinder: FinderElementBuilding{
    //element type
    public typealias Element = FinderElement<S.Point>;
    
    public func buildElement(cost c: Int, from parent: Element?, to point: Element.Point, inVisited: Element?) -> Element? {
        let f = self.getH(point);
        guard let parent = parent else {
            return Element(point: point, f: f, parent: nil);
        }
        
        guard let _ = inVisited else {
            return Element(point: point, f: f, parent: parent);
        }
        return .None;
    }
    
    
    public mutating func find(start: S.Point, goal: S.Point, source: S) -> [S.Point]?{
        self.getH = {
            return H.heuristic(from: $0, to: goal);
        }
        let delegate = FinderDelegate<Element>();
        let path = _FinderProcessor.execute(from: start, to: goal, delegate: delegate, builder: self, source: source);
        return path[goal];
    }

}
/*
next :
CGFloat int,
tile break out(diagonal = false),
check neighbor passable
multi start & multi goal
....
**/

