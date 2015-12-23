//
//  FinderImpl.swift
//  X_Framework
//
//  Created by 173 on 15/12/16.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//MARK: == FinderDelegate ==
public struct FinderDelegate<Request: FinderRequestType where Request.Point: Hashable> {
    ///element type
    public typealias Element = FinderElement<Request.Point>;

    ///open list
    private(set) var openList: PriorityArray<Element>;

    ///visite list
    private(set) var visiteList: [Request.Point: Element];
    
    ///finder request
    public var request: Request;
    
    ///init
    public init(request: Request){
        self.request = request;
        self.openList = PriorityArray.init(minimum: []);
        self.visiteList = [:];
    }
}
extension FinderDelegate {
    ///insert element and set element visited
    mutating public func insert(element: Element){
        self.openList.insert(element);
        self.visiteList[element.point] = element;
    }

    ///update element
    mutating public func update(element: Element) {
        guard let i = (self.openList.indexOf{$0 == element}) else {return;}
        self.openList.replace(element, at: i);
        self.visiteList[element.point] = element;
    }
}
extension FinderDelegate: FinderDelegateType{
    ///get the visited element and return it, or nil if no visited element exists at point.
    public subscript(point: Request.Point) -> Element? {
        return self.visiteList[point];
    }

    ///return next element
    /// - Requires: set element closed
    mutating public func next() -> Element?{
        guard var element = self.openList.popBest() else {return .None;}
        element.closed = true;
        self.visiteList[element.point] = element;
        return element;
    }
}

//MARK: == FinderRequest ==
public struct FinderRequest<Point: Hashable> {
    ///origin point
    public private(set) var origin: Point;
    
    ///goal
    public private(set) var goal: Point?;
    
    public private(set) var goals: [Point]?;
    
    ///is completion
    public private(set) var isCompletion: Bool = false;
    
    ///init single goal
    public init(origin: Point, goal: Point){
        self.origin = origin;
        self.goal = goal;
    }
    
    ///init multi goal
    public init(origin: Point, goals: [Point]){
        self.origin = origin;
        self.goals = goals;
    }
}
extension FinderRequest: FinderRequestType {
    ///point is target return true otherwise return false
    mutating public func findTarget(point: Point) -> Bool {
        guard let g = self.goal else{
            guard let i = self.goals?.indexOf(point) else {return false;}
            self.goals!.removeAtIndex(i);
            self.isCompletion = (self.goals?.isEmpty)!;
            return true;
        }
        
        guard g == point else{return false;}
        self.isCompletion = true;
        return true;
    }
}

////MARK: == GreedyBestFinder ==
//public struct GreedyBestFinder <S: FinderDataSourceType, H: FinderHeuristicType where S.Point == H.Point>{
//    
//    var _heuristic: H!
//    mutating func find(from start: S.Point, to goal: S.Point, at source: S) -> [S.Point: [S.Point]] {
//        var delegate = FinderDelegate(source: source, request: FinderRequest(origin: start, goal: goal));
//        return delegate._execute{
//            let point = $0;
//            let parent = $1;
//            guard delegate[point] == .None else {return;}
//            var element: Element;
//            let h = Int(self._heuristic.heuristicOf(from: point, to: self._goal) * 10);
//            if let parent = parent {
//                guard let _ = self.source.getCost(from: parent.point, to: point) else {return;}
//                element = Element(point: point, f: h, parent: parent);
//            }
//            else{
//                element = Element(point: point, f: h, parent: .None);
//            }
//            self.generator.insert(element);
//        }!
//    }
//}





//
////MARK: == BreadthBestPathFinder ==
//public struct BreadthBestPathFinder<S: FinderDataSourceType>{
//    ///source
//    public var source: S;
//
//    //open list
//    private(set) var openList: [S.Point];
//
//    //visite list
//    private(set) var visiteList: [S.Point: S.Point];
//
//    //current index
//    private var currentIndex: Int = 0;
//    
//    private var origin: S.Point?
//
//    //init
//    public init(source: S){
//        self.source = source;
//        self.openList = [];
//        self.visiteList = [:];
//        self.currentIndex = 0;
//    }
//}
//extension BreadthBestPathFinder: FinderMultiType, FinderDelegateType {
//    ///return point of element
//    public func pointOf(element: S.Point) -> S.Point {
//        return element;
//    }
//    
//    ///backtrace
//    public func backtrace(element: S.Point) -> [S.Point] {
//        var point = element;
//        var result: [S.Point] = [point];
//        repeat{
//            guard let p = self.visiteList[point] else {break;}
//            result.append(p);
//            point = p;
//        }while true
//        return result;
//    }
//    
//    ///back trace explored record; return [point: came from point]
//    public func backtraceRecord() -> [S.Point: S.Point]{
//        return self.visiteList;
//    }
//
//    ///return next element
//    public mutating func next() -> S.Point? {
//        guard currentIndex < self.openList.count else{return nil;}
//        return self.openList[self.currentIndex++];
//    }
//
//    ///explore
//    mutating public func explore(point: S.Point, from parent: S.Point?) {
//        if let p = parent{
//            guard self.visiteList[point] == .None && point != origin else {return;}
//            guard let _ = self.source.getCost(from: p, to: point) else {return;}
//        }
//        self.openList.append(point);
//        self.visiteList[point] = parent;
//    }
//
//    ///find execute, return result from point to point
//    mutating public func find(from f: S.Point, to t: S.Point) -> [S.Point] {
//        self.reset(f);
//        return self.execute(f, target: t);
//    }
//
//    ///find result from f to t
//    mutating public func find(from points: [S.Point], to point: S.Point) -> [S.Point: [S.Point]] {
//        self.reset(point);
//        var targets = points;
//        return self.execute(point, targets: &targets);
//    }
//
//    ///reset
//    mutating private func reset(o: S.Point){
//        self.openList = [];
//        self.visiteList = [:];
//        self.currentIndex = 0;
//        self.origin = o;
//    }
//}
//
////MARK: == FinderElement ==
//public struct FinderElement<P: Hashable>: FinderChainable {
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
//extension FinderElement: Comparable{}
//public func ==<P>(lsh: FinderElement<P>, rsh: FinderElement<P>) -> Bool{
//    return lsh.point == rsh.point;
//}
//public func <<P>(lsh: FinderElement<P>, rsh: FinderElement<P>) -> Bool{
//    return lsh.f < rsh.f;
//}
//
////MARK: == FinderGenerator ==
//public struct FinderGenerator<E: FinderElementType where E: Comparable>{
//    
//    //open list
//    private(set) var openList: PriorityArray<E>;
//    
//    //visite list
//    private(set) var visiteList: [E.Point: E];
//    
//    //init with single target and source
//    public init(){
//        self.openList = PriorityArray{
//            return $0 < $1
//        }
//        self.visiteList = [:];
//    }
//}
//extension FinderGenerator {
//    ///insert element and set element visited
//    mutating public func insert(element: E){
//        self.openList.insert(element);
//        self.visiteList[element.point] = element;
//    }
//    
//    ///update element
//    mutating public func update(element: E) {
//        guard let i = (self.openList.indexOf{$0 == element}) else {return;}
//        self.openList.replace(element, at: i);
//        self.visiteList[element.point] = element;
//    }
//    
//    ///return visited element at point
//    public subscript(point: E.Point) -> E? {
//        return self.visiteList[point];
//    }
//}
//extension FinderGenerator: GeneratorType{
//    
//    ///pop best element and set element closed
//    mutating public func next() -> E?{
//        guard var element = self.openList.popBest() else {return .None;}
//        element.isClosed = true;
//        self.visiteList[element.point] = element;
//        return element;
//    }
//}
//
////MARK: == GreedyBestFinder ==
//public struct GreedyBestFinder<S: FinderDataSourceType, H: FinderHeuristicType where S.Point == H.Point>{
//    
//    ///source
//    public var source: S;
//    
//    ///delegate
//    private var generator: FinderGenerator<Element>!;
//    
//    /// heuristic
//    private let _heuristic: H;
//    
//    ///goal
//    private var _goal: S.Point!;
//    
//    //init
//    public init(source: S, heuristic: H){
//        self.source = source;
//        self._heuristic = heuristic;
//    }
//}
//extension GreedyBestFinder: FinderType, FinderDelegateType{
//    
//    ///element type
//    public typealias Element = FinderElement<S.Point>;
//    
//    ///back trace explored record; return [point: came from point]
//    public func backtraceRecord() -> [S.Point: S.Point] {
//        var d: [S.Point: S.Point] = [:];
//        self.generator.visiteList.forEach{
//            guard let parent = $1.parent as? Element else{return;}
//            d[$0] = parent.point;
//        }
//        return d;
//    }
//    
//    ///return next element
//    public mutating func next() -> Element? {
//        return self.generator.next();
//    }
//    
//    ///explore
//    mutating public func explore(point: S.Point, from parent: Element?) {
//        guard self.generator[point] == .None else {return;}
//        var element: Element;
//        let h = Int(self._heuristic.heuristicOf(from: point, to: self._goal) * 10);
//        if let parent = parent {
//            guard let _ = self.source.getCost(from: parent.point, to: point) else {return;}
//            element = Element(point: point, f: h, parent: parent);
//        }
//        else{
//            element = Element(point: point, f: h, parent: .None);
//        }
//        self.generator.insert(element);
//    }
//    
//    ///find execute, return result from point to point
//    mutating public func find(from f: S.Point, to t: S.Point) -> [S.Point] {
//        self._goal = t;
//        self.generator = FinderGenerator<Element>();
//        return self.execute(f, target: t);
//    }
//}
//
////MARK: == DijkstraPathFinder ==
//public struct DijkstraPathFinder<S: FinderDataSourceType>{
//    
//    ///source
//    public var source: S;
//    
//    ///delegate
//    private var generator: FinderGenerator<Element>!;
//
//    //init
//    public init(source: S){
//        self.source = source;
//    }
//}
//extension DijkstraPathFinder: FinderMultiType, FinderDelegateType{
//    ///element type
//    public typealias Element = FinderElement<S.Point>;
//    
//    ///back trace explored record; return [point: came from point]
//    public func backtraceRecord() -> [S.Point: S.Point] {
//        var d: [S.Point: S.Point] = [:];
//        self.generator.visiteList.forEach{
//            guard let parent = $1.parent as? Element else{return;}
//            d[$0] = parent.point;
//        }
//        return d;
//    }
//    
//    ///return next element
//    public mutating func next() -> Element? {
//        return self.generator.next();
//    }
//    
//    ///explore
//    mutating public func explore(point: S.Point, from parent: Element?) {
//        guard let p = parent else{
//            let element = Element(point: point, f: 0, parent: .None);
//            self.generator.insert(element);
//            return;
//        }
//        
//        guard let cost = source.getCost(from: p.point, to: point) else {return;}
//        let g = p.f + cost;
//        guard var visited = self.generator[point] else {
//            let element = Element(point: point, f: g, parent: p);
//            self.generator.insert(element);
//            return;
//        }
//        guard !visited.isClosed && g < visited.f else {return}
//        visited.update(g, parent: p);
//        self.generator.update(visited);
//    }
//    
//    ///find execute, return result from point to point
//    mutating public func find(from f: S.Point, to t: S.Point) -> [S.Point] {
//        self.generator = FinderGenerator<Element>();
//        return self.execute(f, target: t);
//    }
//    
//    ///find result from f to t
//    mutating public func find(from points: [S.Point], to point: S.Point) -> [S.Point: [S.Point]] {
//        self.generator = FinderGenerator<Element>();
//        var targets = points;
//        return self.execute(point, targets: &targets);
//    }
//}
//
////MARK: == FinderAstarElement ==
//public struct FinderAstarElement<P: Hashable>: FinderChainable {
//    
//    //point
//    public private(set) var point: P;
//    
//    //parent
//    public private(set) var parent: Any?
//    
//    //g
//    public private(set) var g: Int;
//    
//    //h
//    public private(set) var h: Int;
//    
//    //f valuep
//    public private(set) var f: Int;
//    
//    //is closed
//    public var isClosed: Bool = false;
//    
//    //init
//    public init(point: P, g: Int, h: Int, parent: Any?){
//        self.point = point;
//        self.g = g;
//        self.h = h;
//        self.f = g + h;
//        self.parent = parent;
//    }
//}
//extension FinderAstarElement: FinderElementType {
//    public mutating func update(g: Int, parent: FinderAstarElement) {
//        self.g = g;
//        self.f = self.g + self.h;
//        self.parent = parent;
//    }
//}
//extension FinderAstarElement: Comparable{}
//public func ==<P>(lsh: FinderAstarElement<P>, rsh: FinderAstarElement<P>) -> Bool{
//    return lsh.point == rsh.point;
//}
//public func <<P>(lsh: FinderAstarElement<P>, rsh: FinderAstarElement<P>) -> Bool{
//    guard lsh.f < rsh.f else{
//        return lsh.h < rsh.h;
//    }
//    return true;
//}
//
////MARK: == AstarFinder ==
//public struct AstarFinder<S: FinderDataSourceType, H: FinderHeuristicType where S.Point == H.Point>{
//    
//    ///source
//    public var source: S;
//    
//    ///delegate
//    private var generator: FinderGenerator<Element>!;
//    
//    /// heuristic
//    private let _heuristic: H;
//    
//    ///goal
//    private var _goal: S.Point!;
//    
//    //init
//    public init(source: S, heuristic: H){
//        self.source = source;
//        self._heuristic = heuristic;
//    }
//}
//extension AstarFinder: FinderType, FinderDelegateType{
//    
//    ///element type
//    public typealias Element = FinderAstarElement<S.Point>;
//    
//    ///back trace explored record; return [point: came from point]
//    public func backtraceRecord() -> [S.Point: S.Point] {
//        var d: [S.Point: S.Point] = [:];
//        self.generator.visiteList.forEach{
//            guard let parent = $1.parent as? Element else{return;}
//            d[$0] = parent.point;
//        }
//        return d;
//    }
//    
//    ///return next element
//    public mutating func next() -> Element? {
//        return self.generator.next();
//    }
//    
//    ///explore
//    mutating public func explore(point: S.Point, from parent: Element?) {
//        guard let p = parent else{
//            let h = Int(self._heuristic.heuristicOf(from: point, to: self._goal) * 10);
//            let element = Element(point: point, g: 0, h: h, parent: .None);
//            self.generator.insert(element);
//            return;
//        }
//        
//        guard let cost = source.getCost(from: p.point, to: point) else {return;}
//        let g = p.g + cost * 10;
//        guard var visited = self.generator[point] else {
//            let h = Int(self._heuristic.heuristicOf(from: point, to: self._goal) * 10);
//            let element = Element(point: point, g: g, h: h, parent: parent);
//            self.generator.insert(element);
//            return;
//        }
//        guard !visited.isClosed && g < visited.g else {return}
//        visited.update(g, parent: p);
//        self.generator.update(visited);
//    }
//    
//    ///find execute, return result from point to point
//    mutating public func find(from f: S.Point, to t: S.Point) -> [S.Point] {
//        self._goal = t;
//        self.generator = FinderGenerator<Element>();
//        return self.execute(f, target: t);
//    }
//}