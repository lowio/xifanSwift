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

///MARK: extension FinderType where 'Self'.Request == FinderRequest
extension FinderType where Self.Request == FinderRequest<Self.Source.Point> {
    ///Returns result from start to goal -- [start point: [path point]]
    /// - Parameters:
    ///     - request: request
    ///     - source: data source
    mutating public func find(from start: Source.Point, to goal: Source.Point, source: Source) -> [Source.Point: [Source.Point]] {
        let request = FinderRequest(origin: start, goal: goal);
        return self.find(request, source: source);
    }
}
///MARK: extension FinderMultiType where 'Self'.Request == FinderRequest
extension FinderMultiType where Self.Request == FinderRequest<Self.Source.Point> {
    ///Returns result from start to goal -- [start point: [path point]]
    /// - Parameters:
    ///     - request: request
    ///     - source: data source
    mutating public func find(from points: [Source.Point], to goal: Source.Point, source: Source) -> [Source.Point: [Source.Point]] {
        guard points.count > 1 else {
            return self.find(from: points[0], to: goal, source: source);
        }
        let request = FinderRequest(origin: goal, goals: points);
        return self.find(request, source: source);
    }
}



//MARK: == GreedyBestFinder ==
public struct GreedyBestFinder <S: FinderDataSourceType, H: FinderHeuristicType where S.Point == H.Point>{
    
    private var _heuristic: H
    
    public init(heuristic: H){
        self._heuristic = heuristic;
    }
}
extension GreedyBestFinder: FinderType {
    public func find(request: FinderRequest<S.Point>, source: S) -> [S.Point : [S.Point]] {
        guard let goal = request.goal else {return [:];}
        var delegate = FinderDelegate(request: request);
        return delegate._execute(source){
            let point = $0;
            guard delegate[point] == .None || source.getCost(point) == .None else {return;}
            let h = Int(self._heuristic.heuristicOf(from: point, to: goal) * 10);
            let ele = FinderElement(point: point, g: 0, h: h, backward: $1?.point);
            delegate.insert(ele);
        } ?? [:];
    }
}

//MARK: == AstarFinder ==
public struct AstarFinder <S: FinderDataSourceType, H: FinderHeuristicType where S.Point == H.Point>{
    
    private var _heuristic: H
    
    public init(heuristic: H){
        self._heuristic = heuristic;
    }
}
extension AstarFinder: FinderType {
    public func find(request: FinderRequest<S.Point>, source: S) -> [S.Point : [S.Point]] {
        guard let goal = request.goal else {return [:];}
        var delegate = FinderDelegate(request: request);
        return delegate._execute(source){
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
        } ?? [:];
    }
}

//MARK: == DijkstraPathFinder ==
public struct DijkstraPathFinder<S: FinderDataSourceType> {}
extension DijkstraPathFinder: FinderMultiType {
    public func find(request: FinderRequest<S.Point>, source: S) -> [S.Point : [S.Point]] {
        var delegate = FinderDelegate(request: request);
        return delegate._execute(source){
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
        } ?? [:];
    }
}

//MARK: == BreadthBestPathFinder ==
public struct BreadthBestPathFinder<S: FinderDataSourceType> {}
extension BreadthBestPathFinder: FinderMultiType {
    public func find(request: FinderRequest<S.Point>, source: S) -> [S.Point : [S.Point]] {
        var delegate = FinderDelegate(request: request);
        return delegate._execute(source){
            let point = $0;
            guard let _ = source.getCost(point) where delegate[point] == .None else {return;}
            let parent = $1;
            var g = 0;
            if let _parent = parent {
                g = _parent.g + 1;
            }
            let ele = FinderElement(point: point, g: g, h: 0, backward: parent?.point);
            delegate.insert(ele);
        } ?? [:];
    }
}