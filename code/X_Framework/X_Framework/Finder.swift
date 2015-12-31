//
//  Finder.swift
//  X_Framework
//
//  Created by 173 on 15/12/2.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//MARK: == FinderElement ==
public struct FinderElement<Point: Hashable> {
    ///element is closed
    public internal(set) var closed: Bool = false;

    ///g
    public private(set) var g: CGFloat;

    ///h
    public private(set) var h: CGFloat;

    ///f = g + h
    public private(set) var f: CGFloat;
    
    ///point
    public private(set) var point: Point;
    
    ///backward point
    public private(set) var backward: Point?;

    ///init
    public init(point: Point, g: CGFloat, h: CGFloat, backward: Point?){
        self.g = g;
        self.h = h;
        self.f = g + h;
        self.point = point;
        self.backward = backward;
    }
}
extension FinderElement: Comparable{}
public func ==<P>(lsh: FinderElement<P>, rsh: FinderElement<P>) -> Bool{
    return lsh.point == rsh.point;
}
public func <<P>(lsh: FinderElement<P>, rsh: FinderElement<P>) -> Bool{
    guard lsh.f < rsh.f else{
        return lsh.h < rsh.h;
    }
    return true;
}

//MARK: == FinderModel ==
public enum FinderModel {
    case Straight, Diagonal
}

//MARK: == FinderOptionType ==
public protocol FinderOptionType{
    ///point type
    typealias Point: Hashable;
    
    ///model
    var model: FinderModel{get}
    
    ///return neighbors of point
    func neighborsOf(point: Point) -> [Point]
    
    ///return calculate movement cost from f to t if it is validity(and exist)
    ///otherwise return nil
    func calculateCost(from f: Point, to t: Point) -> CGFloat?
    
    ///return estimate h value from f point to t point
    func estimateCost(from f: Point, to t: Point) -> CGFloat
}

//MARK: == FinderRequestType ==
public protocol FinderRequestType{
    ///point type
    typealias Point: Hashable;
    
    ///is completion
    var isCompletion: Bool{get}
    
    ///point is target return true otherwise return false
    mutating func findTarget(point: Point) -> Bool
}

//MARK: == FinderDelegateType ==
public protocol FinderDelegateType: GeneratorType{
    ///point type
    typealias Point: Hashable;
    
    ///element type
    typealias Element = FinderElement<Point>;
    
    ///return next element
    /// - Requires: set element closed
    mutating func next() -> Element?
    
    ///insert element
    /// - Requires: set element visited
    mutating func insert(element: Element)

    ///update element
    mutating func update(element: Element)
    
    ///get the visited element and return it, or nil if no visited element exists at point.
    subscript(point: Point) -> Element? {get}
    
    ///return visited record
    func backtraceRecord() -> [Element]
}
extension FinderDelegateType where Self.Element == FinderElement<Point> {
    ///back trace points
    func backtrace(element: Element) -> [Point]{
        let point = element.point;
        var result: [Point] = [point]
        var e = element;
        repeat{
            guard let backward = e.backward else{break;}
            result.append(backward);
            guard let be = self[backward] else {break;}
            e = be;
        }while true;
        return result;
    }
}

//MARK: == FinderType ==
public protocol FinderType{
    ///delegate type
    typealias Delegate: FinderDelegateType;
    
    ///delegate
    var delegate: Delegate{get set}
    
    ///Returns result of request with option -- [start point: [path point]]
    /// - Parameters:
    ///     - request: request
    ///     - with option: option
    @warn_unused_result
    mutating func find<
        Opt: FinderOptionType,
        Req: FinderRequestType
        where
        Opt.Point == Delegate.Point,
        Opt.Point == Delegate.Point
        >(request: Req, with option: Opt) -> [Opt.Point: [Opt.Point]]
}
extension FinderType {
    ///return visited record
    public func backtraceRecord() -> [Delegate.Element] {
        return self.delegate.backtraceRecord();
    }
}
extension FinderType where Self.Delegate.Element == FinderElement<Self.Delegate.Point> {
    ///Generate element at point from element
    ///Return touple that .visited is true self.update(.element) else self.insert(.element)
    public typealias Generation = (point: Delegate.Point, from: Delegate.Element?) -> (element: Delegate.Element, visited: Bool)?
    
    ///Returns result of request use option start exploring at orign
    /// - Parameters:
    ///     - origin: point of start exploring
    ///     - request: FinderRequestType
    ///     - option: FinderOptionType
    ///     - generate: return (element: element of point, visited: point is visited)?; visited is true update else insert
    @warn_unused_result
    mutating public func find<
        Opt: FinderOptionType,
        Req: FinderRequestType
        where
        Opt.Point == Delegate.Point,
        Req.Point == Delegate.Point>
        (inout request: Req, from origin: Opt.Point, with option: Opt, @noescape generation: Generation) -> [Opt.Point: [Opt.Point]]
    {
        var result: [Opt.Point: [Opt.Point]] = [:];
        guard !request.isCompletion else {return result;}
        guard let ge = generation(point: origin, from: .None) where !ge.visited else {return result;}
        self.delegate.insert(ge.element);
        repeat{
            guard let element = self.delegate.next() else{break;}
            let point = element.point;
            if request.findTarget(point){
                result[point] = self.delegate.backtrace(element);
            }
            guard !request.isCompletion else {break;}
            let neighbors = option.neighborsOf(point);
            neighbors.forEach{
                guard let ge = generation(point: $0, from: element) else {return;}
                ge.visited ? self.delegate.update(ge.element) : self.delegate.insert(ge.element);
            }
        }while true
        return result;
    }
}

//MARK: == FinderSingleType ==
public protocol FinderSingleType: FinderType {
    
    ///request type
    typealias Request: FinderRequestType;
    
    ///return request
    func requestGenerate(from: Request.Point, to: Request.Point) -> Request
}
extension FinderSingleType where Self.Request.Point == Self.Delegate.Point {
    ///Returns result from start to goal -- [start point: [path point]]
    /// - Parameters:
    ///     - from: start point
    ///     - to: goal point
    ///     - source: data source
    @warn_unused_result
    mutating public func find<
        Opt: FinderOptionType
        where
        Opt.Point == Request.Point
        >(from start: Opt.Point, to goal: Opt.Point, option: Opt) -> [Opt.Point: [Opt.Point]]
    {
        let request = self.requestGenerate(start, to: goal);
        return self.find(request, with: option);
    }
}
//
//MARK: == FinderMultiType ==
public protocol FinderMultiType: FinderSingleType {
    ///return request
    func requestGenerate(from: [Request.Point], to: Request.Point) -> Request
}
extension FinderMultiType where Self.Request.Point == Self.Delegate.Point {
    ///Returns result list from start to goal -- [start point: [path point]]
    /// - Parameters:
    ///     - from: start points
    ///     - to: goal point
    ///     - source: data source
    @warn_unused_result
    mutating public func find<
        Opt: FinderOptionType
        where
        Opt.Point == Request.Point
        >(from points: [Opt.Point], to goal: Opt.Point, option: Opt) -> [Opt.Point: [Opt.Point]]
    {
        let request = self.requestGenerate(points, to: goal);
        return self.find(request, with: option);
    }
}

/**
a star path
**/