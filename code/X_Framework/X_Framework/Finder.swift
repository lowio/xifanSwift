//
//  Finder.swift
//  X_Framework
//
//  Created by 173 on 15/12/2.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//MARK: == FinderElement ==
public protocol FinderElementType {
    //point type
    typealias Point: Hashable;
    
    //point
    var point: Self.Point {get}
    
    //init
    init(point: Self.Point)
}

//MARK: == FinderSourceType ==
public protocol FinderSourceType {
    
    //point type
    typealias Point: Hashable;
    
    //return neighbors(passable) of point
    func neighborsOf(point: Self.Point) -> [Self.Point];
    
    //return cost
    func costOf(point: Self.Point, _ toPoint: Self.Point) -> CGFloat
    
    //return h
    func heuristicOf(point: Self.Point, _ toPoint: Self.Point) -> CGFloat
}

//MARK: == FinderDelegateType ==
public protocol FinderDelegateType{
    //element type
    typealias Element: FinderElementType;
    
    //pop best element(close the element)
    mutating func popBest() -> Self.Element?
    
    //insert element
    mutating func insert(element: Self.Element)
    
    //update element
    mutating func update(element: Self.Element)
    
    //subscript, return visited element of point
    subscript(point: Self.Element.Point) -> Self.Element? {get}
    
    //decompress path
    func decompressPath(element: Self.Element) -> [Self.Element.Point]
    
    //decompress path record
    func decompressPathRecord() -> [Self.Element]
    
    init();
}

//MARK: == FinderType ==
public protocol FinderType {
    
    //element type
    typealias Element: FinderElementType;
    
    //explore point
    func explore<S: FinderSourceType, D: FinderDelegateType where D.Element == Self.Element, S.Point == D.Element.Point>(point: S.Point, parent: D.Element, source: S, inout delegate: D)

    //find path, return path from start to goal
    mutating func find<S: FinderSourceType where S.Point == Self.Element.Point>(start: S.Point, goal: S.Point, source: S) -> [S.Point]

    //find paths, return paths from start to goals
    mutating func find<S: FinderSourceType where S.Point == Self.Element.Point>(start: S.Point, goals: [S.Point], source: S) -> [[S.Point]]
}
extension FinderType{
    //point type
    typealias P = Self.Element.Point;
    
    //execute
    mutating public func execute<D: FinderDelegateType, S: FinderSourceType where D.Element == Self.Element, S.Point == P>(origin: P, source: S, inout delegate: D, @noescape _ isTerminal: (Self.Element) -> Bool) {
        let oe = Self.Element(point: origin);
        delegate.insert(oe);
        repeat{
            guard let current = delegate.popBest() else {break;}
            let point = current.point;
            guard !isTerminal(current) else {break;}
            let neighbors = source.neighborsOf(point);
            neighbors.forEach{
                self.explore($0, parent: current, source: source, delegate: &delegate);
            }
        }while true
    }
}


////MARK: == AstarPathFinder ==
//public struct AstarPathFinder<FD: FinderDelegateType>
//{
//    var heristics: ((FD.Element.Point) -> CGFloat)!
//}
//extension AstarPathFinder: FinderType{
//    
//    public typealias Element = FD.Element;
//    
//    public func explore<S : FinderSourceType, D : FinderDelegateType where D.Element == FD.Element, S.Point == D.Element.Point>(point: S.Point, parent: D.Element, source: S, inout delegate: D) {
////        let h = self.heristics(point);
//////        let g = parent.g + source.costOf(parent.point, point);
////        guard let v = delegate[point] else {
//////            return Element(g: g, h: h, position: position, parent: p);
////        }
////        guard !v.isClosed && g < v.g else {return nil;}
////        var element = v;
////        element.setParent(p, g: g);
////        return element;
//    }
//    
//    mutating public func find<S : FinderSourceType where S.Point == AstarPathFinder.Element.Point>(start: S.Point, goal: S.Point, source: S) -> [S.Point] {
//        self.heristics = {
//            source.heuristicOf($0, goal);
//        }
//        
//        var path:[S.Point]?;
//        var delegate = FD();
//        self.execute(start, source: source, delegate: &delegate){
//            let ele = $0;
//            guard ele.point == goal else {return false;}
//            path = delegate.decompressPath(ele);
//            return true;
//        }
//        
//        return path ?? [];
//    }
//    
//    mutating public func find<S : FinderSourceType where S.Point == AstarPathFinder.Element.Point>(start: S.Point, goals: [S.Point], source: S) -> [[S.Point]] {
//        self.heristics = {
//            source.heuristicOf($0, goals[0]);
//        }
//        
//        var paths:[[S.Point]] = [];
//        var delegate = FD();
//        self.execute(start, source: source, delegate: &delegate){
//            let ele = $0;
//            guard ele.point == goals[0] else {return false;}
//            let path = delegate.decompressPath(ele);
//            paths.append(path);
//            return true;
//        }
//        
//        return paths;
//    }
//}
