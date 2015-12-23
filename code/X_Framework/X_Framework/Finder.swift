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

//MARK: == FinderRequestType ==
public protocol FinderRequestType{
    ///point type
    typealias Point;
    
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
    typealias Point: Hashable = Request.Point;
    
    ///request type
    typealias Request: FinderRequestType;
    
    ///finder request
    var request: Request{set get}
    
    ///init
    init(request: Request)
    
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
extension FinderDelegateType
    where
    Self.Request.Point == Self.Point
{
    ///Returns result of request in source
    /// - Parameters: 
    ///     - explore: explore point function
    mutating public func _execute<Source: FinderDataSourceType where Source.Point == Point>
        (source: Source, @noescape explore: (point: Point, backwardElement: FinderElement<Point>?) -> Void) -> [Point: [Point]]?
    {
        guard !request.isCompletion else {return .None;}
        explore(point: request.origin, backwardElement: .None);
        var result: [Point: [Point]] = [:];
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
//    ///delegate type
//    typealias Delegate: FinderDelegateType;
//    
//    ///Returns result of request from source -- [start point: [path point]]
//    /// - Parameters: 
//    ///     - request: request
//    ///     - source: data source
//    mutating func find(request: Delegate.Request, source: Delegate.Source) -> [Delegate.Point: [Delegate.Point]]
}


////MARK: == FinderType ==
//public protocol FinderType {
//    
//    ///finder source type
//    typealias Source: FinderDataSourceType;
//    
//    ///find result from start point to goal point
//    mutating func find(from start: Source.Point, to goal: Source.Point, at source: Source) -> [Source.Point]
//}
//
////MARK: == FinderMultiType ==
//public protocol FinderMultiType: FinderType {
//    ///find result from points to point
//    mutating func find(from points: [Source.Point], to point: Source.Point) -> [Source.Point: [Source.Point]]
//}


//extension FinderMultiType
//    where
//    Self: FinderDelegateType,
//    Self.Point == Self.Source.Point {
//    
//    ///execute multi targets
//    mutating public func execute(origin: Source.Point, inout targets: [Source.Point]) -> [Source.Point: [Source.Point]] {
//        var result: [Source.Point: [Source.Point]] = [:];
//        guard targets.count > 1 else {
//            let p = targets[0];
//            result[p] = self.execute(p, target: origin);
//            return result;
//        }
//        
//        self.execute(origin){
//            let e = $0;
//            let p = self.pointOf(e);
//            guard let i = targets.indexOf(p) else{return false;}
//            result[p] = self.backtrace(e);
//            targets.removeAtIndex(i);
//            return targets.isEmpty;
//        }
//        return result;
//    }
//}

//MARK: == FinderHeuristicType ==
public protocol FinderHeuristicType{
    typealias Point;
    
    //heristic h value
    func heuristicOf(from f: Point, to t: Point) -> CGFloat
}


////MARK: == FinderElementType ==
//public protocol FinderElementType {
//    ///point type
//    typealias Point: Hashable;
//    
//    ///point
//    var point: Point{get}
//    
//    ///element is closed
//    var isClosed: Bool{get set}
//}
//
////MARK: == FinderChainable ==
//public protocol FinderChainable {
//    //parent
//    var parent: Any?{get}
//}
//
////MARK: == FinderDataSource ==
//public protocol FinderDataSourceType {
//    
//    //point type
//    typealias Point: Hashable;
//    
//    //return neighbors of point
//    func neighborsOf(point: Point) -> [Point];
//    
//    ///return cost from f point to t point if it is passable
//    ///otherwise return nil
//    func getCost(from f: Point, to t: Point) -> Int?
//}
//
////MARK: == FinderDelegateType ==
//public protocol FinderDelegateType: GeneratorType{
//    
//    ///element type
//    typealias Point: Hashable;
//    
//    ///back trace points
//    func backtrace(element: Element) -> [Point]
//    
//    ///back trace explored record; return [point: came from point]
//    func backtraceRecord() -> [Point: Point]
//    
//    ///return point of element
//    func pointOf(element: Element) -> Point
//    
//    ///return neighbor points around point
//    func neighborsOf(point: Point) -> [Point]
//    
//    ///explore point from parent element
//    mutating func explore(point: Point, from parent: Element?)
//}
//extension FinderDelegateType {
//    ///execute
//    /// - Requires: isTerminal if all goals was found return true, otherwise return false;
//    mutating public func execute(origin: Point, @noescape _ isTerminal: (Element) -> Bool) {
//        self.explore(origin, from: nil);
//        repeat{
//            guard let element = self.next() else{break;}
//            guard !isTerminal(element) else {break;}
//            let point = self.pointOf(element);
//            let neighbors = self.neighborsOf(point);
//            neighbors.forEach{
//                self.explore($0, from: element);
//            }
//        }while true
//    }
//}
//extension FinderDelegateType
//    where
//Self.Element: FinderElementType {
//    
//    ///return point of element
//    public func pointOf(element: Element) -> Element.Point{
//        return element.point;
//    }
//}
//extension FinderDelegateType
//    where
//Self.Element: FinderChainable {
//    ///back trace points
//    public func backtrace(element: Element) -> [Point]{
//        let point = pointOf(element);
//        var result: [Point] = [point]
//        var e = element;
//        repeat{
//            guard let parent = e.parent as? Element else{break;}
//            let p = pointOf(parent);
//            result.append(p);
//            e = parent;
//        }while true;
//        return result;
//    }
//}
//
////MARK: == FinderType ==
//public protocol FinderType {
//    ///finder source type
//    typealias Source: FinderDataSourceType;
//    
//    ///source
//    var source: Source{get set}
//    
//    ///find result from f to t
//    mutating func find(from f: Source.Point, to t: Source.Point) -> [Source.Point]
//}
//extension FinderType
//    where
//    Self: FinderDelegateType,
//Self.Point == Self.Source.Point {
//    
//    ///execute single target
//    mutating public func execute(origin: Source.Point, target: Source.Point) -> [Source.Point] {
//        var result: [Source.Point] = [];
//        self.execute(origin){
//            let e = $0
//            let p = self.pointOf(e);
//            guard p == target else{return false;}
//            result = self.backtrace(e);
//            return true;
//        }
//        return result;
//    }
//    
//    ///return neighbor points around point
//    public func neighborsOf(point: Point) -> [Point]{
//        return self.source.neighborsOf(point);
//    }
//}
//
////MARK: == FinderMultiType ==
//public protocol FinderMultiType: FinderType {
//    ///find result from f to t
//    mutating func find(from points: [Source.Point], to point: Source.Point) -> [Source.Point: [Source.Point]]
//}
//extension FinderMultiType
//    where
//    Self: FinderDelegateType,
//Self.Point == Self.Source.Point {
//    
//    ///execute multi targets
//    mutating public func execute(origin: Source.Point, inout targets: [Source.Point]) -> [Source.Point: [Source.Point]] {
//        var result: [Source.Point: [Source.Point]] = [:];
//        guard targets.count > 1 else {
//            let p = targets[0];
//            result[p] = self.execute(p, target: origin);
//            return result;
//        }
//        
//        self.execute(origin){
//            let e = $0;
//            let p = self.pointOf(e);
//            guard let i = targets.indexOf(p) else{return false;}
//            result[p] = self.backtrace(e);
//            targets.removeAtIndex(i);
//            return targets.isEmpty;
//        }
//        return result;
//    }
//}
//
////MARK: == FinderHeuristicType ==
//public protocol FinderHeuristicType{
//    typealias Point;
//    
//    //heristic h value
//    func heuristicOf(from f: Point, to t: Point) -> CGFloat
//}


/*
next :
tile break out(diagonal = false)
guard lsh.f < rsh.f else{
return lsh.h < rsh.h;
}
....
**/

