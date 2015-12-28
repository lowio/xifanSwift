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
extension FinderSingleType where Self: FinderType, Self.Request == FinderRequest<Self.Point> {
    ///return request
    public func requestGenerate(from: Point, to: Point) -> Request{
        return FinderRequest(origin: from, goal: to);
    }
}
///MARK: extension FinderMultiType where 'Self'.Request == FinderRequest
extension FinderMultiType where Self: FinderType, Self.Request == FinderRequest<Self.Point> {
    ///return request
    public func requestGenerate(from: [Point], to: Point) -> Request{
        return FinderRequest(origin: to, goals: from);
    }
}

//MARK: == GreedyBestFinder ==
public struct GreedyBestFinder<P: Hashable> {}
extension GreedyBestFinder: FinderSingleType{
    public typealias Point = P;
}
extension GreedyBestFinder: FinderType {
    ///Returns result of request from source -- [start point: [path point]]
    /// - Parameters:
    ///     - request: request
    ///     - source: data source
    @warn_unused_result
    public func find<Opt: FinderOptionType where Opt.Point == Point>(request: FinderRequest<Point>, option: Opt) -> FinderResult<Point>? {
        guard let goal = request.goal else {return .None;}
        var request = request;
        var delegate = FinderDelegate<Point>();
        let result = delegate.find(request.origin, request: &request, option: option, generate: {
            let point = $0;
            guard delegate[point] == .None else {return .None;}
            if let bp = $1?.point where option.calculateCost(from: bp, to: point) == .None{return .None;}
            let h = option.estimateCost(from: point, to: goal);
            return (FinderElement(point: point, g: 0, h: h, backward: $1?.point), false);
        });
        return FinderResult(result: result, delegate: delegate);
    }
}

//MARK: == AstarFinder ==
public struct AstarFinder<P: Hashable> {}
extension AstarFinder: FinderSingleType{
    public typealias Point = P;
}
extension AstarFinder:  FinderType {
    ///Returns result of request from source -- [start point: [path point]]
    /// - Parameters:
    ///     - request: request
    ///     - source: data source
    @warn_unused_result
    public func find<Opt: FinderOptionType where Opt.Point == Point>(request: FinderRequest<Point>, option: Opt) -> FinderResult<Point>? {
        guard let goal = request.goal else {return .None;}
        var request = request;
        var delegate = FinderDelegate<Point>();
        let result = delegate.find(request.origin, request: &request, option: option, generate: {
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
            guard !visited.closed && g < visited.g else {return .None;}
            return (FinderElement(point: point, g: g, h: visited.h, backward: parent?.point), true);
        });
        return FinderResult(result: result, delegate: delegate);
    }
}

//MARK: == DijkstraPathFinder ==
public struct DijkstraPathFinder<P: Hashable> {}
extension DijkstraPathFinder: FinderMultiType{
    public typealias Point = P;
}
extension DijkstraPathFinder:  FinderType {
    ///Returns result of request from source -- [start point: [path point]]
    /// - Parameters:
    ///     - request: request
    ///     - source: data source
    @warn_unused_result
    public func find<Opt: FinderOptionType where Opt.Point == Point>(request: FinderRequest<Point>, option: Opt) -> FinderResult<Point>? {
        var request = request;
        var delegate = FinderDelegate<Point>();
        let result = delegate.find(request.origin, request: &request, option: option, generate: {
            let point = $0;
            let parent = $1;
            var g: CGFloat = 0;
            if let _parent = parent {
                guard let cost = option.calculateCost(from: _parent.point, to: point) else {return .None;}
                g = _parent.g + cost;
            }
            guard let visited = delegate[point] else {
                return (FinderElement(point: point, g: g, h: 0, backward: parent?.point), false);
            }
            guard !visited.closed && g < visited.g else {return .None;}
            print(g == visited.g, g - visited.g);
            return (FinderElement(point: point, g: g, h: 0, backward: parent?.point), true);
        });
        return FinderResult(result: result, delegate: delegate);
    }
}

//MARK: == BreadthBestPathFinder ==
public struct BreadthBestPathFinder<P: Hashable> {}
extension BreadthBestPathFinder: FinderMultiType{
    public typealias Point = P;
}
extension BreadthBestPathFinder:  FinderType {
    ///Returns result of request from source -- [start point: [path point]]
    /// - Parameters:
    ///     - request: request
    ///     - source: data source
    @warn_unused_result
    public func find<Opt: FinderOptionType where Opt.Point == Point>(request: FinderRequest<Point>, option: Opt) -> FinderResult<Point>? {
        var request = request;
        var delegate = FinderDelegate<Point>();
        var h: CGFloat = 0;
        let result = delegate.find(request.origin, request: &request, option: option, generate: {
            let point = $0;
            guard delegate[point] == .None else {return .None;}
            let parent = $1;
            var g: CGFloat = 0;
            if let _parent = parent {
                g = _parent.g + 1;
                guard let _ = option.calculateCost(from: _parent.point, to: point) else {return .None;}
            }
            return (FinderElement(point: point, g: g, h: h++, backward: parent?.point), false);
        });
        return FinderResult(result: result, delegate: delegate);
    }
}