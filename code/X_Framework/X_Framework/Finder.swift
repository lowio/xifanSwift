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
    
    ///return calculate movement cost from f to t if it is validity
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
    
    ///return next element
    /// - Requires: set element closed
    mutating func next() -> FinderElement<Point>?
    
    ///insert element
    /// - Requires: set element visited
    mutating func insert(element: FinderElement<Point>)

    ///update element
    mutating func update(element: FinderElement<Point>)
    
    ///get the visited element and return it, or nil if no visited element exists at point.
    subscript(point: Point) -> FinderElement<Point>? {get}
}
extension FinderDelegateType{
    ///back trace points
    func backtrace(element: FinderElement<Point>) -> [Point]{
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
extension FinderDelegateType {
    ///Returns result of request use option start exploring at orign
    /// - Parameters: 
    ///     - origin: point of start exploring
    ///     - request: FinderRequestType
    ///     - option: FinderOptionType
    ///     - explore: explore function, 'self'.insert 'self'.update etc...; point - current explore point; backward: backward element
    @warn_unused_result
    mutating public func find<
        Opt: FinderOptionType,
        Req: FinderRequestType
        where
        Opt.Point == Point,
        Req.Point == Point>
        (origin: Point, inout request: Req, option: Opt, @noescape explore: (point: Point, backward: FinderElement<Point>?) -> Void) -> [Point: [Point]]
    {
        var result: [Point: [Point]] = [:];
        guard !request.isCompletion else {return result;}
        explore(point: origin, backward: .None);
        repeat{
            guard let element = self.next() else{break;}
            let point = element.point;
            if request.findTarget(point){
                result[point] = self.backtrace(element);
                guard !request.isCompletion else {break;}
            }
            let neighbors = option.neighborsOf(point);
            neighbors.forEach{
                explore(point: $0, backward: element);
            }
        }while true
        return result;
    }
    
    ///generate element
    public typealias GElement = (element: FinderElement<Point>, visited: Bool)
    
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
        Opt.Point == Point,
        Req.Point == Point>
        (origin: Point, inout request: Req, option: Opt, @noescape generate: (point: Point, backward: FinderElement<Point>?) -> GElement?) -> [Point: [Point]]
    {
        var result: [Point: [Point]] = [:];
        guard !request.isCompletion else {return result;}
        guard let ge = generate(point: origin, backward: .None) where !ge.visited else {return result;}
        self.insert(ge.0);
        repeat{
            guard let element = self.next() else{break;}
            let point = element.point;
            if request.findTarget(point){
                result[point] = self.backtrace(element);
                guard !request.isCompletion else {break;}
            }
            let neighbors = option.neighborsOf(point);
            neighbors.forEach{
                guard let ge = generate(point: $0, backward: element) else {return;}
                ge.1 ? self.update(ge.0) : self.insert(ge.0);
            }
        }while true
        return result;
    }
}

//MARK: == FinderType ==
public protocol FinderType{
    ///request type
    typealias Request: FinderRequestType;
    
    ///Returns result of request from source -- [start point: [path point]]
    /// - Parameters: 
    ///     - request: request
    ///     - source: data source
    @warn_unused_result
    func find<Opt: FinderOptionType where Opt.Point == Request.Point>(request: Request, option: Opt) -> [Opt.Point: [Opt.Point]]
}

//MARK: == FinderSingleType ==
public protocol FinderSingleType: FinderType {
    ///point type
    typealias Point: Hashable;
    
    ///return request
    func requestGenerate(from: Point, to: Point) -> Request
}
extension FinderSingleType where Self.Point == Self.Request.Point{
    ///Returns result from start to goal -- [start point: [path point]]
    /// - Parameters:
    ///     - from: start point
    ///     - to: goal point
    ///     - source: data source
    @warn_unused_result
    public func find<Opt: FinderOptionType where Opt.Point == Point>(from start: Point, to goal: Point, option: Opt) -> [Point: [Point]]{
        let request = self.requestGenerate(start, to: goal);
        return self.find(request, option: option);
    }
}
//
//MARK: == FinderMultiType ==
public protocol FinderMultiType: FinderSingleType {
    ///return request
    func requestGenerate(from: [Point], to: Point) -> Request
}
extension FinderMultiType  where Self.Point == Self.Request.Point{
    ///Returns result list from start to goal -- [start point: [path point]]
    /// - Parameters:
    ///     - from: start points
    ///     - to: goal point
    ///     - source: data source
    @warn_unused_result
    func find<Opt: FinderOptionType where Opt.Point == Point>(from points: [Point], to goal: Point, option: Opt) -> [Point: [Point]] {
        let request = self.requestGenerate(points, to: goal);
        return self.find(request, option: option);
    }
}


////get cost  1 ?? 1.4 (3d?)
////scale g and h