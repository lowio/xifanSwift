//
//  FinderImpl.swift
//  X_Framework
//
//  Created by 173 on 15/12/16.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//MARK: == FinderDelegate ==
public struct FinderDelegate<Point: Hashable> {
    ///element type
    public typealias Element = FinderElement<Point>;

    ///open list
    private(set) var openList: PriorityArray<Element>;

    ///visite list
    private(set) var visiteList: [Point: Element];
    
    ///init
    public init(){
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
    public subscript(point: Point) -> Element? {
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

///MARK: extension FinderType where 'Self'.Request == FinderRequest
extension FinderSingleType where Self: FinderType, Self.Request == FinderRequest<Self.Point> {
    ///Returns result from start to goal -- [start point: [path point]]
    /// - Parameters:
    ///     - from: start point
    ///     - to: goal point
    ///     - source: data source
    public func find<Source: FinderDataSourceType where Source.Point == Point>(from start: Point, to goal: Point, source: Source) -> [Point: [Point]] {
        let request = FinderRequest(origin: start, goal: goal);
        return self.find(request, source: source);
    }
}
///MARK: extension FinderMultiType where 'Self'.Request == FinderRequest
extension FinderMultiType where Self: FinderType, Self.Request == FinderRequest<Self.Point> {
    ///Returns result list from start to goal -- [start point: [path point]]
    /// - Parameters:
    ///     - from: start points
    ///     - to: goal point
    ///     - source: data source
    public func find<Source: FinderDataSourceType where Source.Point == Point>(from points: [Point], to goal: Point, source: Source) -> [Point: [Point]] {
        guard points.count > 1 else {
            return self.find(from: points[0], to: goal, source: source);
        }
        let request = FinderRequest(origin: goal, goals: points);
        return self.find(request, source: source);
    }
}

//MARK: == GreedyBestFinder ==
public struct GreedyBestFinder<P: Hashable, H: FinderHeuristicType where P == H.Point> {
    
    private var _heuristic: H
    
    public init(heuristic: H){
        self._heuristic = heuristic;
    }
}
extension GreedyBestFinder: FinderSingleType{
    public typealias Point = P;
}
extension GreedyBestFinder: FinderType {
    ///Returns result of request in source
    /// - Parameters:
    ///     - explore: explore point function
    @warn_unused_result
    public func find<Source: FinderDataSourceType where Source.Point == Point>(request: FinderRequest<Point>, source: Source) -> [Point: [Point]] {
        guard let goal = request.goal else {return [:];}
        var request = request;
        var delegate = FinderDelegate<Point>();
        return delegate._execute(&request, source: source){
            let point = $0;
            guard delegate[point] == .None || source.getCost(point) == .None else {return;}
            let h = Int(self._heuristic.heuristicOf(from: point, to: goal) * 10);
            let ele = FinderElement(point: point, g: 0, h: h, backward: $1?.point);
            delegate.insert(ele);
        };
    }
}

//MARK: == AstarFinder ==
public struct AstarFinder<P: Hashable, H: FinderHeuristicType where P == H.Point> {
    
    private var _heuristic: H
    
    public init(heuristic: H){
        self._heuristic = heuristic;
    }
}
extension AstarFinder: FinderSingleType{
    public typealias Point = P;
}
extension AstarFinder:  FinderType {
    ///Returns result of request in source
    /// - Parameters:
    ///     - explore: explore point function
    @warn_unused_result
    public func find<Source: FinderDataSourceType where Source.Point == Point>(request: FinderRequest<Point>, source: Source) -> [Point: [Point]] {
        guard let goal = request.goal else {return [:];}
        var request = request;
        var delegate = FinderDelegate<Point>();
        return delegate._execute(&request, source: source){
            let point = $0;
            guard let cost = source.getCost(point) else {return;}
            let parent = $1;
            var g = 0;
            if let _parent = parent {
                g = _parent.g + cost;
            }
            guard let visited = delegate[point] else {
                let h = Int(self._heuristic.heuristicOf(from: point, to: goal) * 10);
                let ele = FinderElement(point: point, g: g, h: h, backward: parent?.point);
                delegate.insert(ele);
                return;
            }
            
            guard !visited.closed && g < visited.g else {return;}
            let ele = FinderElement(point: point, g: g, h: visited.h, backward: parent?.point);
            delegate.update(ele);
        };
    }
}

//MARK: == DijkstraPathFinder ==
public struct DijkstraPathFinder<P: Hashable> {}
extension DijkstraPathFinder: FinderMultiType{
    public typealias Point = P;
}
extension DijkstraPathFinder:  FinderType {
    ///Returns result of request in source
    /// - Parameters:
    ///     - explore: explore point function
    @warn_unused_result
    public func find<Source: FinderDataSourceType where Source.Point == Point>(request: FinderRequest<Point>, source: Source) -> [Point: [Point]] {
        var request = request;
        var delegate = FinderDelegate<Point>();
        return delegate._execute(&request, source: source){
            let point = $0;
            guard let cost = source.getCost(point) else {return;}
            let parent = $1;
            var g = 0;
            if let _parent = parent {
                g = _parent.g + cost;
            }
            guard let visited = delegate[point] else {
                let ele = FinderElement(point: point, g: g, h: 0, backward: parent?.point);
                delegate.insert(ele);
                return;
            }
            
            guard !visited.closed && g < visited.g else {return;}
            let ele = FinderElement(point: point, g: g, h: 0, backward: parent?.point);
            delegate.update(ele);
        };
    }
}

//MARK: == BreadthBestPathFinder ==
public struct BreadthBestPathFinder<P: Hashable> {}
extension BreadthBestPathFinder: FinderMultiType{
    public typealias Point = P;
}
extension BreadthBestPathFinder:  FinderType {
    ///Returns result of request in source
    /// - Parameters:
    ///     - explore: explore point function
    @warn_unused_result
    public func find<Source: FinderDataSourceType where Source.Point == Point>(request: FinderRequest<Point>, source: Source) -> [Point: [Point]] {
        var request = request;
        var delegate = FinderDelegate<Point>();
        return delegate._execute(&request, source: source){
            let point = $0;
            guard let _ = source.getCost(point) where delegate[point] == .None else {return;}
            let parent = $1;
            var g = 0;
            if let _parent = parent {
                g = _parent.g + 1;
            }
            let ele = FinderElement(point: point, g: g, h: 0, backward: parent?.point);
            delegate.insert(ele);
        };
    }
}