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
    typealias Point: Hashable;
    
    //return neighbors of point
    func neighborsOf(point: Point) -> [Point];
    
    ///return cost from f point to t point if it is passable
    ///otherwise return nil
    func getCost(from f: Point, to t: Point) -> Int?
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
    
    ///trace visited record
    func backtraceRecord() -> [Element]
}

//MARK: == FinderType ==
public protocol FinderType{
    //source
    typealias Source: FinderDataSourceType;
    
    ///element type
    typealias Element: FinderElementType;
    
    ///build element
    func buildElement(cost c: Int, from parent: Element?, to point: Element.Point, inVisited: Element?) -> Element?
    
    //find
    mutating func find(from f: Source.Point, to t: Source.Point, source: Source) -> [Source.Point]?
}

//MARK: == FinderMultiType ==
public protocol FinderMultiType: FinderType{
    //find
    mutating func find(from points: [Source.Point], to t: Source.Point, source: Source) -> [Source.Point: [Source.Point]]
}

//MARK: == FinderHeuristicType ==
public protocol FinderHeuristicType{
    typealias Point: Hashable;
    
    //heristic h value
    static func heuristic(from f: Point, to t: Point) -> Int
}

//MARK: == _FinderProcessor ==
public struct _FinderProcessor {
    ///Return track array from origin to goal
    @warn_unused_result
    static public func execute<
        Point,
        Source: FinderDataSourceType,
        Delegate: _FinderDelegateType,
        Finder: FinderType
        where
        Point == Source.Point,
        Source.Point == Finder.Element.Point,
        Delegate.Element == Finder.Element
    >(from origin: Point, to goal: Point, delegate: Delegate, finder: Finder, source: Source) -> [Point: [Point]]{
        return self.execute(delegate, origin: origin, finder: finder, source: source){
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
        Finder: FinderType
        where
        Point == Source.Point,
        Source.Point == Finder.Element.Point,
        Delegate.Element == Finder.Element
    >(inout from points: [Point], to goal: Point, delegate: Delegate, finder: Finder, source: Source) -> [Point: [Point]]{
        guard points.count > 1 else{
            return self.execute(from: goal, to: points[0], delegate: delegate, finder: finder, source: source)
        }
        
        return _FinderProcessor.execute(delegate, origin: goal, finder: finder, source: source){
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
        Finder: FinderType
        where
        Point == Source.Point,
        Source.Point == Finder.Element.Point,
        Delegate.Element == Finder.Element
    >(var delegate: Delegate, origin: Point, finder: Finder, source: Source,
        @noescape _ isTerminal: (Point) -> Bool?) -> [Point: [Point]] {
            guard let origin = finder.buildElement(cost: 0, from: .None, to: origin, inVisited: .None) else {return [:];}
            delegate.insert(origin);
            var paths:[Point: [Point]] = [:];
            repeat{
                guard var element = delegate.next() else{break;}
                element.isClosed = true;
                delegate.updateNoReorder(element);
                let point = element.point;
                if let flag = isTerminal(point){
                    let path = self.backtrace(element);
                    paths[point] = path;
                    guard !flag else{break;}
                }
                let neighbors = source.neighborsOf(element.point);
                neighbors.forEach{
                    let p = $0;
                    guard let cost = source.getCost(from: point, to: p) else {return;}
                    guard let visited = delegate[p] else{
                        guard let ele = finder.buildElement(cost: cost, from: element, to: p, inVisited: .None) else{return;}
                        delegate.insert(ele);
                        return;
                    }
                    guard !visited.isClosed else {return;}
                    guard let ele = finder.buildElement(cost: cost, from: element, to: p, inVisited: visited)else{return;}
                    delegate.updateAndReorder(ele);
                    print("WARN: _FinderProcessorType.execute - delegate.reorder =================");
                }
            }while true
            return paths;
    }
    
    ///return track array
    static public func backtrace<Element: FinderElementType>(element: Element) -> [Element.Point]{
        var ele = element;
        var path = [ele.point];
        repeat{
            guard let p = ele.parent as? Element else {break;}
            ele = p;
            path.append(ele.point);
        }while true
        return path;
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

//MARK: == GreedyBestFinder ==
public struct GreedyBestFinder<S: FinderDataSourceType, H: FinderHeuristicType where S.Point == H.Point>{
    //get h
    private var getH: ((S.Point) -> Int)!
}
extension GreedyBestFinder: FinderType{
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
    
    //find
    public mutating func find(from f: S.Point, to t: S.Point, source: S) -> [S.Point]? {
        self.getH = {
            return H.heuristic(from: $0, to: t);
        }
        let delegate = FinderDelegate<Element>();
        let path = _FinderProcessor.execute(from: f, to: t, delegate: delegate, finder: self, source: source);
        return path[t];
    }
}


//MARK: == DijkstraPathFinder ==
public struct DijkstraPathFinder<S: FinderDataSourceType, H: FinderHeuristicType where S.Point == H.Point>{}
extension DijkstraPathFinder: FinderMultiType{
    //element type
    public typealias Element = FinderElement<S.Point>;
    
    public func buildElement(cost c: Int, from parent: Element?, to point: Element.Point, inVisited: Element?) -> Element? {
        guard let p = parent else{
            return Element(point: point, f: 0, parent: .None);
        }
        
        let g = p.f + c;
        guard var visited = inVisited else {
            return Element(point: point, f: g, parent: p);
        }
        guard !visited.isClosed && g < visited.f else {return .None;}
        visited.update(g, parent: p);
        return visited;
    }
    
    //find
    public func find(from f: S.Point, to t: S.Point, source: S) -> [S.Point]? {
        let delegate = FinderDelegate<Element>();
        let path = _FinderProcessor.execute(from: f, to: t, delegate: delegate, finder: self, source: source);
        return path[t];
    }
    
    //find
    public func find(from points: [S.Point], to t: S.Point, source: S) -> [S.Point : [S.Point]] {
        let delegate = FinderDelegate<Element>();
        var ps = points;
        return _FinderProcessor.execute(from: &ps, to: t, delegate: delegate, finder: self, source: source);
    }
}
//
////MARK: == PFinderQueue ==
//public struct PFinderQueue<T: Hashable>{
//
//    public typealias Element = PathFinderElement<T>
//
//    //open list
//    private(set) var openList: [Element];
//
//    //visite list
//    private(set) var visiteList: [T: Element];
//
//    //current index
//    private var currentIndex: Int = 0;
//
//    init(){
//        self.openList = [];
//        self.visiteList = [:];
//        self.currentIndex = 0;
//    }
//}
//extension PFinderQueue: PathFinderQueueType{
//    //insert element and set element visited
//    mutating public func insert(element: Element){
//        self.openList.append(element);
//        self.visiteList[element.position] = element;
//    }
//
//    //pop best element and set element closed
//    mutating public func popBest() -> Element?{
//        guard currentIndex < self.openList.count else{return nil;}
//        let element = self.openList[self.currentIndex++];
//        return element;
//    }
//
//    //return visited element at position
//    public subscript(position: T) -> Element? {
//        return self.visiteList[position];
//    }
//
//    //return all visited element
//    public func allVisitedList() -> [Element] {
//        return self.visiteList.values.reverse()
//    }
//
//    mutating public func update(element: Element){
//        //do nothing
//    }
//}
//
////MARK: == BreadthBestPathFinder ==
//public struct BreadthBestPathFinder<Request: PathFinderRequestType>{}
//extension BreadthBestPathFinder: PathFinderType{
//    //queue type
//    public typealias Queue = PFinderQueue<Request.Position>;
//
//    //create queue
//    public func queueGenerate() -> Queue {
//        return Queue.init();
//    }
//
//    //search position
//    public func searchPosition(position: Request.Position, _ parent: Queue.Element?, _ visited: Queue.Element?, _ request: Request) -> Queue.Element? {
//        guard let _ = visited else {
//            return Queue.Element(g: 0, h: 0, position: position, parent: parent as? PathFinderChainable);
//        }
//        return nil;
//    }
//}

/*
next :
CGFloat int,
tile break out(diagonal = false),
check neighbor passable
multi start & multi goal
....
**/

