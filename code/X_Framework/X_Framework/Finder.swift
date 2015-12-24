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
    public private(set) var g: Int;

    ///h
    public private(set) var h: Int;

    ///f = g + h
    public private(set) var f: Int;
    
    ///point
    public private(set) var point: Point;
    
    ///backward point
    public private(set) var backward: Point?;

    ///init
    public init(point: Point, g: Int, h: Int, backward: Point?){
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

//MARK: == FinderDataSourceType ==
public protocol FinderDataSourceType {
    //point type
    typealias Point: Hashable;
    
    //return neighbors of point
    func neighborsOf(point: Point) -> [Point];
    
    ///return cost of point if it is passable
    ///otherwise return nil
    func getCost(point: Point) -> Int?
}

//MARK: == FinderRequestType ==
public protocol FinderRequestType{
    ///point type
    typealias Point: Hashable;
    
    ///origin point
    var origin: Point {get}
    
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
    ///Returns result of request in source
    /// - Parameters: 
    ///     - explore: explore point function
    @warn_unused_result
    mutating public func _execute<
        Source: FinderDataSourceType,
        Request: FinderRequestType
        where
        Source.Point == Point,
        Request.Point == Point
        >
        (inout request: Request, source: Source, @noescape explore: (point: Point, backwardElement: FinderElement<Point>?) -> Void) -> [Point: [Point]]
    {
        var result: [Point: [Point]] = [:];
        guard !request.isCompletion else {return result;}
        explore(point: request.origin, backwardElement: .None);
        repeat{
            guard let element = self.next() else{break;}
            let point = element.point;
            if request.findTarget(point){
                result[point] = self.backtrace(element);
                guard !request.isCompletion else {break;}
            }
            let neighbors = source.neighborsOf(point);
            neighbors.forEach{
                explore(point: $0, backwardElement: element);
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
    func find<Source: FinderDataSourceType where Source.Point == Request.Point>(request: Request, source: Source) -> [Source.Point: [Source.Point]]
}

//MARK: == FinderSingleType ==
public protocol FinderSingleType {
    ///point type
    typealias Point: Hashable;
    
    ///Returns result from start to goal -- [start point: [path point]]
    /// - Parameters:
    ///     - from: start point
    ///     - to: goal point
    ///     - source: data source
    @warn_unused_result
    func find<Source: FinderDataSourceType where Source.Point == Point>(from start: Point, to goal: Point, source: Source) -> [Point: [Point]]
}

//MARK: == FinderMultiType ==
public protocol FinderMultiType: FinderSingleType {
    ///Returns result list from start to goal -- [start point: [path point]]
    /// - Parameters:
    ///     - from: start points
    ///     - to: goal point
    ///     - source: data source
    @warn_unused_result
    func find<Source: FinderDataSourceType where Source.Point == Point>(from points: [Point], to goal: Point, source: Source) -> [Point: [Point]]
}

//MARK: == FinderHeuristicType ==
public protocol FinderHeuristicType{
    typealias Point;
    
    //heristic h value
    func heuristicOf(from f: Point, to t: Point) -> CGFloat
}