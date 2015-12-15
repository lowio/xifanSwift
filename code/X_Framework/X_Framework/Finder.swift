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
    ///point type
    typealias Point: Hashable;
    
    ///point
    var point: Point{get}
    
    ///element is closed
    var isClosed: Bool{get set}
}
//MARK: == FinderChainable ==
public protocol FinderChainable {
    //parent
    var parent: Any?{get}
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

//MARK: == FinderType ==
public protocol FinderType: GeneratorType {
    ///finder source type
    typealias Source: FinderDataSourceType;
    
    ///source
    var source: Source{get}
    
    ///back trace points
    func backtrace(element: Element) -> [Source.Point]
    
    ///explore point
    mutating func _explore(point: Source.Point, from parent: Element?)
    
    ///find result from f to t
    mutating func find(from f: Source.Point, to t: Source.Point) -> [Source.Point]
}
extension FinderType
    where
    Self.Element: FinderElementType,
    Self.Element.Point == Self.Source.Point {
    
    ///execute single target
    mutating public func _execute(origin: Source.Point, target: Source.Point) -> [Source.Point] {
        var result: [Source.Point] = [];
        self._execute(origin){
            let e = $0;
            guard e.point == target else{return false;}
            result = self.backtrace(e);
            return true;
        }
        return result;
    }
    
    ///execute
    /// - Requires: isTerminal if all goals was found return true, otherwise return false;
    mutating public func _execute(origin: Source.Point, @noescape _ isTerminal: (Element) -> Bool) {
        self._explore(origin, from: nil);
        repeat{
            guard let element = self.next() else{break;}
            guard !isTerminal(element) else {break;}
            let point = element.point;
            let neighbors = self.source.neighborsOf(point);
            neighbors.forEach{
                self._explore($0, from: element);
            }
        }while true
    }
}
extension FinderType
    where
    Self.Element: FinderChainable,
    Self.Element: FinderElementType,
    Self.Element.Point == Self.Source.Point{
    ///back trace points
    public func backtrace(element: Element) -> [Source.Point]{
        var result: [Source.Point] = [element.point]
        var e = element;
        repeat{
            guard let p = e.parent as? Element else{break;}
            result.append(p.point);
            e = p;
        }while true;
        return result;
    }
}

//MARK: == FinderMultiType ==
public protocol FinderMultiType: FinderType {
    ///find result from f to t
    mutating func find(from points: [Source.Point], to point: Source.Point) -> [Source.Point: [Source.Point]]
}
extension FinderMultiType
    where
    Self.Element: FinderElementType,
    Self.Element.Point == Self.Source.Point {
    
    ///execute multi targets
    mutating public func _execute(origin: Source.Point, inout targets: [Source.Point]) -> [Source.Point: [Source.Point]] {
        var result: [Source.Point: [Source.Point]] = [:];
        guard targets.count > 1 else {
            let p = targets[0];
            result[p] = self._execute(p, target: origin);
            return result;
        }
        
        self._execute(origin){
            let e = $0;
            let p = e.point;
            guard let i = targets.indexOf(p) else{return false;}
            result[p] = self.backtrace(e);
            targets.removeAtIndex(i);
            return targets.isEmpty;
        }
        return result;
    }
}

//MARK: == FinderHeuristicType ==
public protocol FinderHeuristicType{
    typealias Point;
    
    //heristic h value
    func heuristic(from f: Point, to t: Point) -> Int
}

//MARK: == FinderDelegate ==
public struct FinderDelegate<E: FinderElementType where E: Comparable>{

    //open list
    private(set) var openList: PriorityQueue<E>;

    //visite list
    private(set) var visiteList: [E.Point: E];

    //init with single target and source
    public init(){
        self.openList = PriorityQueue{
            return $0 < $1
        }
        self.visiteList = [:];
    }
}
extension FinderDelegate {
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
extension FinderDelegate: GeneratorType{
    
    ///pop best element and set element closed
    mutating public func next() -> E?{
        guard var element = self.openList.popBest() else {return .None;}
        element.isClosed = true;
        self.visiteList[element.point] = element;
        return element;
    }
}

//MARK: == FinderElement ==
public struct FinderElement<P: Hashable>: FinderChainable {
    
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
extension FinderElement: Comparable{}
public func ==<P>(lsh: FinderElement<P>, rsh: FinderElement<P>) -> Bool{
    return lsh.point == rsh.point;
}
public func <<P>(lsh: FinderElement<P>, rsh: FinderElement<P>) -> Bool{
    return lsh.f < rsh.f;
}

//MARK: == GreedyBestFinder ==
public struct GreedyBestFinder<S: FinderDataSourceType, H: FinderHeuristicType where S.Point == H.Point>{
    
    ///source
    public private(set) var source: S;
    
    ///delegate
    public private(set) var delegate: Generator!;
    
    /// heuristic
    private let _heuristic: H;
    
    ///goal
    private var _goal: S.Point!;
    
    //init
    public init(source: S, heuristic: H){
        self.source = source;
        self._heuristic = heuristic;
    }
}
extension GreedyBestFinder: FinderType{
    
    ///element type
    public typealias Element = FinderElement<S.Point>;
    
    ///generator type
    public typealias Generator = FinderDelegate<Element>;
    
    ///return next element
    public mutating func next() -> Element? {
        return self.delegate.next();
    }
    
    ///explore
    mutating public func _explore(point: S.Point, from parent: Element?) {
        guard self.delegate[point] == .None else {return;}
        let h = self._heuristic.heuristic(from: point, to: self._goal);
        let element = Element(point: point, f: h, parent: parent);
        self.delegate.insert(element);
    }
    
    ///find execute, return result from point to point
    mutating public func find(from f: S.Point, to t: S.Point) -> [S.Point] {
        self._goal = t;
        self.delegate = Generator();
        return self._execute(f, target: t);
    }
}

//MARK: == DijkstraPathFinder ==
public struct DijkstraPathFinder<S: FinderDataSourceType>{
    
    ///source
    public private(set) var source: S;
    
    ///delegate
    public private(set) var delegate: Generator!;
    
    //init
    public init(source: S){
        self.source = source;
    }
}
extension DijkstraPathFinder: FinderMultiType{
    ///element type
    public typealias Element = FinderElement<S.Point>;
    
    ///generator type
    public typealias Generator = FinderDelegate<Element>;
    
    ///return next element
    public mutating func next() -> Element? {
        return self.delegate.next();
    }
    
    ///explore
    mutating public func _explore(point: S.Point, from parent: Element?) {
        guard let p = parent else{
            let element = Element(point: point, f: 0, parent: .None);
            self.delegate.insert(element);
            return;
        }
        
        guard let cost = source.getCost(from: p.point, to: point) else {return;}
        let g = p.f + cost;
        guard var visited = self.delegate[point] else {
            let element = Element(point: point, f: g, parent: p);
            self.delegate.insert(element);
            return;
        }
        guard !visited.isClosed && g < visited.f else {return}
        visited.update(g, parent: p);
        self.delegate.update(visited);
    }
    
    ///find execute, return result from point to point
    mutating public func find(from f: S.Point, to t: S.Point) -> [S.Point] {
        self.delegate = Generator();
        return self._execute(f, target: t);
    }
    
    ///find result from f to t
    mutating public func find(from points: [S.Point], to point: S.Point) -> [S.Point: [S.Point]] {
        self.delegate = Generator();
        var targets = points;
        return self._execute(point, targets: &targets);
    }
}

//MARK: == BreadthBestPathFinder ==
public struct BreadthBestPathFinder<S: FinderDataSourceType>{
    ///source
    public private(set) var source: S;
    
    //open list
    private(set) var openList: [Element];

    //visite list
    private(set) var visiteList: [S.Point: Element];

    //current index
    private var currentIndex: Int = 0;
    
    //init
    public init(source: S){
        self.source = source;
        self.openList = [];
        self.visiteList = [:];
        self.currentIndex = 0;
    }
}
extension BreadthBestPathFinder: FinderMultiType {
    ///element type
    public typealias Element = FinderElement<S.Point>;
    
    ///return next element
    public mutating func next() -> Element? {
        guard currentIndex < self.openList.count else{return nil;}
        var element = self.openList[self.currentIndex++];
        element.isClosed = true;
        self.visiteList[element.point] = element;
        return element;
    }
    
    ///explore
    mutating public func _explore(point: S.Point, from parent: Element?) {
        guard self.visiteList[point] == .None else {return;}
        let element = Element(point: point, f: 0, parent: parent);
        self.openList.append(element);
        self.visiteList[point] = element;
    }
    
    ///find execute, return result from point to point
    mutating public func find(from f: S.Point, to t: S.Point) -> [S.Point] {
        self.reset();
        return self._execute(f, target: t);
    }
    
    ///find result from f to t
    mutating public func find(from points: [S.Point], to point: S.Point) -> [S.Point: [S.Point]] {
        self.reset();
        var targets = points;
        return self._execute(point, targets: &targets);
    }
    
    ///reset
    mutating private func reset(){
        self.openList = [];
        self.visiteList = [:];
        self.currentIndex = 0;
    }
}

//MARK: == FinderAstarElement ==
public struct FinderAstarElement<P: Hashable>: FinderChainable {
    
    //point
    public private(set) var point: P;
    
    //parent
    public private(set) var parent: Any?
    
    //g
    public private(set) var g: Int;
    
    //h
    public private(set) var h: Int;
    
    //f valuep
    public private(set) var f: Int;
    
    //is closed
    public var isClosed: Bool = false;
    
    //init
    public init(point: P, g: Int, h: Int, parent: Any?){
        self.point = point;
        self.g = g;
        self.h = h;
        self.f = g + h;
        self.parent = parent;
    }
}
extension FinderAstarElement: FinderElementType {
    public mutating func update(g: Int, parent: FinderAstarElement) {
        self.g = g;
        self.f = self.g + self.h;
        self.parent = parent;
    }
}
extension FinderAstarElement: Comparable{}
public func ==<P>(lsh: FinderAstarElement<P>, rsh: FinderAstarElement<P>) -> Bool{
    return lsh.point == rsh.point;
}
public func <<P>(lsh: FinderAstarElement<P>, rsh: FinderAstarElement<P>) -> Bool{
    return lsh.f < rsh.f;
}

//MARK: == AstarFinder ==
public struct AstarFinder<S: FinderDataSourceType, H: FinderHeuristicType where S.Point == H.Point>{
    
    ///source
    public private(set) var source: S;
    
    ///delegate
    public private(set) var delegate: Generator!;
    
    /// heuristic
    private let _heuristic: H;
    
    ///goal
    private var _goal: S.Point!;
    
    //init
    public init(source: S, heuristic: H){
        self.source = source;
        self._heuristic = heuristic;
    }
}
extension AstarFinder: FinderType{
    
    ///element type
    public typealias Element = FinderAstarElement<S.Point>;
    
    ///generator type
    public typealias Generator = FinderDelegate<Element>;
    
    ///return next element
    public mutating func next() -> Element? {
        return self.delegate.next();
    }
    
    ///explore
    mutating public func _explore(point: S.Point, from parent: Element?) {
        guard let p = parent else{
            let h = self._heuristic.heuristic(from: point, to: self._goal);
            let element = Element(point: point, g: 0, h: h, parent: .None);
            self.delegate.insert(element);
            return;
        }
        
        guard let cost = source.getCost(from: p.point, to: point) else {return;}
        let g = p.g + cost;
        guard var visited = self.delegate[point] else {
            let h = self._heuristic.heuristic(from: point, to: self._goal);
            let element = Element(point: point, g: g, h: h, parent: parent);
            self.delegate.insert(element);
            return;
        }
        guard !visited.isClosed && g < visited.g else {return}
        visited.update(g, parent: p);
        self.delegate.update(visited);
    }
    
    ///find execute, return result from point to point
    mutating public func find(from f: S.Point, to t: S.Point) -> [S.Point] {
        self._goal = t;
        self.delegate = Generator();
        return self._execute(f, target: t);
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

