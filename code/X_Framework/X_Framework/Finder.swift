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

//MARK: == FinderDelegateType ==
public protocol FinderDelegateType: GeneratorType{
    
    ///element type
    typealias Point;
    
    ///back trace points
    func backtrace(element: Element) -> [Point]
    
    ///back trace explored record
    func backtraceRecord() -> [Element]
    
    ///return point of element
    func pointOf(element: Element) -> Point
    
    ///return neighbor points around point
    func neighborsOf(point: Point) -> [Point]
    
    ///explore point from parent element
    mutating func explore(point: Point, from parent: Element?)
}
extension FinderDelegateType {
    ///execute
    /// - Requires: isTerminal if all goals was found return true, otherwise return false;
    mutating public func execute(origin: Point, @noescape _ isTerminal: (Element) -> Bool) {
        self.explore(origin, from: nil);
        repeat{
            guard let element = self.next() else{break;}
            guard !isTerminal(element) else {break;}
            let point = self.pointOf(element);
            let neighbors = self.neighborsOf(point);
            neighbors.forEach{
                self.explore($0, from: element);
            }
        }while true
    }
}
extension FinderDelegateType
    where
    Self.Element: FinderElementType {
    
    ///return point of element
    public func pointOf(element: Element) -> Element.Point{
        return element.point;
    }
}
extension FinderDelegateType
    where
    Self.Element: FinderChainable {
    ///back trace points
    public func backtrace(element: Element) -> [Point]{
        let point = pointOf(element);
        var result: [Point] = [point]
        var e = element;
        repeat{
            guard let parent = e.parent as? Element else{break;}
            let p = pointOf(parent);
            result.append(p);
            e = parent;
        }while true;
        return result;
    }
}

//MARK: == FinderType ==
public protocol FinderType {
    ///finder source type
    typealias Source: FinderDataSourceType;
    
    ///source
    var source: Source{get set}
    
    ///find result from f to t
    mutating func find(from f: Source.Point, to t: Source.Point) -> [Source.Point]
}
extension FinderType
    where
    Self: FinderDelegateType,
    Self.Point == Self.Source.Point {
    
    ///execute single target
    mutating public func execute(origin: Source.Point, target: Source.Point) -> [Source.Point] {
        var result: [Source.Point] = [];
        self.execute(origin){
            let e = $0
            let p = self.pointOf(e);
            guard p == target else{return false;}
            result = self.backtrace(e);
            return true;
        }
        return result;
    }
    
    ///return neighbor points around point
    public func neighborsOf(point: Point) -> [Point]{
        return self.source.neighborsOf(point);
    }
}

//MARK: == FinderMultiType ==
public protocol FinderMultiType: FinderType {
    ///find result from f to t
    mutating func find(from points: [Source.Point], to point: Source.Point) -> [Source.Point: [Source.Point]]
}
extension FinderMultiType
    where
    Self: FinderDelegateType,
    Self.Point == Self.Source.Point {
    
    ///execute multi targets
    mutating public func execute(origin: Source.Point, inout targets: [Source.Point]) -> [Source.Point: [Source.Point]] {
        var result: [Source.Point: [Source.Point]] = [:];
        guard targets.count > 1 else {
            let p = targets[0];
            result[p] = self.execute(p, target: origin);
            return result;
        }
        
        self.execute(origin){
            let e = $0;
            let p = self.pointOf(e);
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
    func heuristicOf(from f: Point, to t: Point) -> CGFloat
}

/*
next :
CGFloat int,
tile break out(diagonal = false),
check neighbor passable
multi start & multi goal
....
**/

