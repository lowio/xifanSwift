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
    
    ///backtrace record
    public func backtraceRecord() -> [Element] {
        return visiteList.values.reverse();
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
    
    ///insert element and set element visited
    mutating public func insert(element: Element){
        self.openList.insert(element);
        self.visiteList[element.point] = element;
    }
    
    ///update element
    mutating public func update(element: Element) {
        print("WARN: FinderDelegate.update ===============")
        guard let i = (self.openList.indexOf{$0 == element}) else {return;}
        self.openList.replace(element, at: i);
        self.visiteList[element.point] = element;
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
extension FinderSingleType where Self.Request == FinderRequest<Self.Delegate.Point> {
    ///return request
    public func requestGenerate(from: Request.Point, to: Request.Point) -> FinderRequest<Self.Delegate.Point>{
        return FinderRequest(origin: from, goal: to);
    }
}
///MARK: extension FinderMultiType where 'Self'.Request == FinderRequest
extension FinderMultiType where Self.Request == FinderRequest<Self.Delegate.Point> {
    ///return request
    public func requestGenerate(from: [Request.Point], to: Request.Point) -> FinderRequest<Self.Delegate.Point>{
        return FinderRequest(origin: to, goals: from);
    }
}

//MARK: == GreedyBestFinder ==
public struct GreedyBestFinder<Point: Hashable> {
    ///delegate
    public var delegate: FinderDelegate<Point>;
}
extension GreedyBestFinder: FinderSingleType{}
extension GreedyBestFinder: FinderType {
    ///Returns result of request with option -- [start point: [path point]]
    /// - Parameters:
    ///     - request: request
    ///     - with option: option
    @warn_unused_result
    mutating public func find<
        Opt: FinderOptionType,
        Req: FinderRequestType
        where
        Opt.Point == Point,
        Opt.Point == Point
        >(request: Req, with option: Opt) -> [Point: [Point]]
    {
        guard var request = request as? FinderRequest<Point>, let goal = request.goal else {return [:]}
        self.delegate = FinderDelegate<Point>();
        return self.find(&request, from: request.origin, with: option){
            let point = $0;
            guard delegate[point] == .None else {return .None;}
            if let bp = $1?.point where option.calculateCost(from: bp, to: point) == .None{return .None;}
            let h = option.estimateCost(from: point, to: goal);
            return (FinderElement(point: point, g: 0, h: h, backward: $1?.point), false);
        }
    }
}

//MARK: == AstarFinder ==
public struct AstarFinder<Point: Hashable> {
    ///delegate
    public var delegate: FinderDelegate<Point>;
}
extension AstarFinder: FinderSingleType{}
extension AstarFinder:  FinderType {
    ///Returns result of request with option -- [start point: [path point]]
    /// - Parameters:
    ///     - request: request
    ///     - with option: option
    @warn_unused_result
    mutating public func find<
        Opt: FinderOptionType,
        Req: FinderRequestType
        where
        Opt.Point == Point,
        Opt.Point == Point
        >(request: Req, with option: Opt) -> [Point: [Point]]
    {
        guard var request = request as? FinderRequest<Point>, let goal = request.goal else {return [:]}
        self.delegate = FinderDelegate<Point>();
        return self.find(&request, from: request.origin, with: option){
            let point = $0;
            let parent = $1;
            var g: CGFloat = 0;
            if let _parent = parent {
                guard let cost = option.calculateCost(from: _parent.point, to: point) else {return .None;}
                g = _parent.g + cost;
            }
            guard let visited = delegate[point] else {
                let h = option.estimateCost(from: point, to: goal);
                return (FinderElement(point: point, g: g, h: h, backward: parent?.point), false);
            }
//            return .None;
            guard !visited.closed && g < visited.g else {return .None;}
            return (FinderElement(point: point, g: g, h: visited.h, backward: parent?.point), true);
        }
    }
}

//MARK: == DijkstraPathFinder ==
public struct DijkstraPathFinder<Point: Hashable> {
    ///delegate
    public var delegate: FinderDelegate<Point>;
}
extension DijkstraPathFinder: FinderMultiType{}
extension DijkstraPathFinder:  FinderType {
    ///Returns result of request with option -- [start point: [path point]]
    /// - Parameters:
    ///     - request: request
    ///     - with option: option
    @warn_unused_result
    mutating public func find<
        Opt: FinderOptionType,
        Req: FinderRequestType
        where
        Opt.Point == Point,
        Opt.Point == Point
        >(request: Req, with option: Opt) -> [Point: [Point]]
    {
        guard var request = request as? FinderRequest<Point> else {return [:]}
        self.delegate = FinderDelegate<Point>();
        var h: CGFloat = 0;
        return self.find(&request, from: request.origin, with: option){
            let point = $0;
            let parent = $1;
            var g: CGFloat = 0;
            h += 1;
            if let _parent = parent {
                guard let cost = option.calculateCost(from: _parent.point, to: point) else {return .None;}
                g = _parent.g + cost;
            }
            guard let visited = delegate[point] else {
                return (FinderElement(point: point, g: g, h: h, backward: parent?.point), false);
            }
            guard !visited.closed && g < visited.g else {return .None;}
            return (FinderElement(point: point, g: g, h: h, backward: parent?.point), true);
        }
    }
}

//MARK: == BreadthBestPathFinder ==
public struct BreadthBestPathFinder<Point: Hashable> {
    ///delegate
    public var delegate: FinderDelegate<Point>;
}
extension BreadthBestPathFinder: FinderMultiType{}
extension BreadthBestPathFinder:  FinderType {
    ///Returns result of request with option -- [start point: [path point]]
    /// - Parameters:
    ///     - request: request
    ///     - with option: option
    @warn_unused_result
    mutating public func find<
        Opt: FinderOptionType,
        Req: FinderRequestType
        where
        Opt.Point == Point,
        Opt.Point == Point
        >(request: Req, with option: Opt) -> [Point: [Point]]
    {
        guard var request = request as? FinderRequest<Point> else {return [:]}
        self.delegate = FinderDelegate<Point>();
        var h: CGFloat = 0;
        return self.find(&request, from: request.origin, with: option){
            let point = $0;
            guard self.delegate[point] == .None else {return .None;}
            let parent = $1;
            var g: CGFloat = 0;
            if let _parent = parent {
                g = _parent.g + 1;
                guard let _ = option.calculateCost(from: _parent.point, to: point) else {return .None;}
            }
            h += 1;
            return (FinderElement(point: point, g: g, h: h, backward: parent?.point), false);
        }
    }
}