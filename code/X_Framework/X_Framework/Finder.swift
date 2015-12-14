//
//  Finder.swift
//  X_Framework
//
//  Created by 173 on 15/12/2.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

///MARK: == FinderElementType ==
public protocol FinderElementType {
    ///point type
    typealias Point;
    
    ///point
    var point: Point{get}
    
    ///element is closed
    var isClosed: Bool{get set}
}

///MARK: == FinderDataSource ==
public protocol FinderDataSourceType {
    
    //point type
    typealias Point: Hashable;
    
    //return neighbors of point
    func neighborsOf(point: Point) -> [Point];
    
    ///return cost from f point to t point if it is passable
    ///otherwise return nil
    func getCost(from f: Point, to t: Point) -> Int?
}

///MARK: == FinderGeneratorType ==
public protocol FinderGeneratorType: GeneratorType {
    
    ///element type
    typealias Element: FinderElementType;
    
    ///return next element
    /// - Requires: close it
    mutating func next() -> Self.Element?
    
    //source type
    typealias Source: FinderDataSourceType;
    
    //source type
    var source: Source{get}
}
extension FinderGeneratorType where Source.Point == Element.Point{
    ///execute single target
    @warn_unused_result
    mutating public func execute<Delegate: FinderDelegateType where Self == Delegate.Generator>
        (origin: Element.Point, target: Element.Point, delegate: Delegate) -> Element?{
            var element: Element?
            self.execute(origin, delegate: delegate){
                let ele = $0;
                guard ele.point == target else {return false;}
                element = ele;
                return true;
            }
            return element;
    }

    ///execute multi targets
    @warn_unused_result
    mutating public func execute<Delegate: FinderDelegateType where Self == Delegate.Generator>
        (inout targets: [Element.Point], to point: Element.Point, delegate: Delegate) -> [Element] {
            var paths: [Element] = [];
            guard targets.count < 2 else{
                self.execute(point, delegate: delegate){
                    let element = $0;
                    let p = element.point;
                    guard let i = targets.indexOf(p) else {return false;}
                    targets.removeAtIndex(i);
                    paths.append(element);
                    return targets.isEmpty;
                }
                return paths;
            }
            
            guard let path = self.execute(point, target: targets[0], delegate: delegate) else {return paths;}
            paths.append(path);
            return paths;
    }
    
    ///Return storage
    /// - Requires: isTerminal if all goals was found return true, otherwise return false;
    mutating public func execute<Delegate: FinderDelegateType where Self == Delegate.Generator>
        (origin: Element.Point, delegate: Delegate, @noescape _ isTerminal: (Element) -> Bool) {
            delegate.explore(origin, from: nil, storage: &self);
            repeat{
                guard let element = self.next() else{break;}
                guard !isTerminal(element) else {break;}
                let point = element.point;
                let neighbors = source.neighborsOf(point);
                neighbors.forEach{
                    delegate.explore($0, from: element, storage: &self);
                }
            }while true
    }
}

///MARK: == FinderDelegateType ==
public protocol FinderDelegateType{
    ///finder generator type
    typealias Generator: FinderGeneratorType;
    
    ///explore point
    func explore(point: Generator.Element.Point, from parent: Generator.Element?, inout storage: Generator)
}

//MARK: == FinderType ==
public protocol FinderType{
    //source
    typealias Source: FinderDataSourceType;
    
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
    typealias Point;
    
    //heristic h value
    static func heuristic(from f: Point, to t: Point) -> Int
}


//MARK: == FinderStorager ==
public struct FinderStorager<E: FinderElementType, S: FinderDataSourceType where E: Comparable, E.Point == S.Point>{

    //open list
    private(set) var openList: PriorityQueue<E>;

    //visite list
    private(set) var visiteList: [S.Point: E];
    
    //source
    public private(set) var source: S;
}
extension FinderStorager {
    //init
    public init(source: S){
        self.source = source;
        self.openList = PriorityQueue{
            return $0 < $1
        }
        self.visiteList = [:];
    }
    
    
    ///insert element and set element visited
    mutating public func insert(element: E){
        self.openList.insert(element);
        self.visiteList[element.point] = element;
    }
    
    ///update element
    mutating public func update(element: E) {
        guard let i = (self.openList.indexOf{$0 == element}) else {return;}
        self.openList.replaceElement(element, atIndex: i);
        self.visiteList[element.point] = element;
    }
    
    ///return visited element at point
    public subscript(point: E.Point) -> E? {
        return self.visiteList[point];
    }
    
    ///trace visited record
    public func backtraceRecord() -> [E]{
        return self.visiteList.values.reverse();
    }
}
extension FinderStorager: FinderGeneratorType{
    ///pop best element and set element closed
    mutating public func next() -> E?{
        guard var element = self.openList.popBest() else {return .None;}
        element.isClosed = true;
        self.visiteList[element.point] = element;
        return element;
    }
}

//
//
////MARK: == FinderElement ==
//public struct FinderElement<P: Hashable> {
//    
//    //point
//    public private(set) var point: P;
//    
//    //parent
//    public private(set) var parent: Any?
//    
//    //f valuep
//    public private(set) var f: Int;
//    
//    //is closed
//    public var isClosed: Bool = false;
//    
//    //init
//    public init(point: P, f: Int, parent: Any?){
//        self.point = point;
//        self.f = f;
//        self.parent = parent;
//    }
//}
//extension FinderElement: FinderElementType {
//    public mutating func update(f: Int, parent: FinderElement) {
//        self.f = f;
//        self.parent = parent;
//    }
//}
//
////MARK: == GreedyBestFinder ==
//public struct GreedyBestFinder<S: FinderDataSourceType, H: FinderHeuristicType where S.Point == H.Point>{
//    //get h
//    private var getH: ((S.Point) -> Int)!
//}
//extension GreedyBestFinder: FinderType{
//    //element type
//    public typealias Element = FinderElement<S.Point>;
//    
//    public func buildElement(cost c: Int, from parent: Element?, to point: Element.Point, inVisited: Element?) -> Element? {
//        let f = self.getH(point);
//        guard let parent = parent else {
//            return Element(point: point, f: f, parent: nil);
//        }
//        
//        guard let _ = inVisited else {
//            return Element(point: point, f: f, parent: parent);
//        }
//        return .None;
//    }
//    
//    //find
//    public mutating func find(from f: S.Point, to t: S.Point, source: S) -> [S.Point]? {
//        self.getH = {
//            return H.heuristic(from: $0, to: t);
//        }
//        let delegate = FinderDelegate<Element>();
//        let path = _FinderProcessor.execute(from: f, to: t, delegate: delegate, finder: self, source: source);
//        return path[t];
//    }
//}


////MARK: == DijkstraPathFinder ==
//public struct DijkstraPathFinder<S: FinderDataSourceType, H: FinderHeuristicType where S.Point == H.Point>{}
//extension DijkstraPathFinder: FinderMultiType{
//    //element type
//    public typealias Element = FinderElement<S.Point>;
//    
//    public func buildElement(cost c: Int, from parent: Element?, to point: Element.Point, inVisited: Element?) -> Element? {
//        guard let p = parent else{
//            return Element(point: point, f: 0, parent: .None);
//        }
//        
//        let g = p.f + c;
//        guard var visited = inVisited else {
//            return Element(point: point, f: g, parent: p);
//        }
//        guard !visited.isClosed && g < visited.f else {return .None;}
//        visited.update(g, parent: p);
//        return visited;
//    }
//    
//    //find
//    public func find(from f: S.Point, to t: S.Point, source: S) -> [S.Point]? {
//        let delegate = FinderDelegate<Element>();
//        let path = _FinderProcessor.execute(from: f, to: t, delegate: delegate, finder: self, source: source);
//        return path[t];
//    }
//    
//    //find
//    public func find(from points: [S.Point], to t: S.Point, source: S) -> [S.Point : [S.Point]] {
//        let delegate = FinderDelegate<Element>();
//        var ps = points;
//        return _FinderProcessor.execute(from: &ps, to: t, delegate: delegate, finder: self, source: source);
//    }
//}
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

