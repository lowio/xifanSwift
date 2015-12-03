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

//MARK: == FinderRequestType ==
public protocol FinderRequestType{
    
    //point type
    typealias Point;
    
    //origin
    var origin: Self.Point{get}
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
    
    //request type
    typealias Request: FinderRequestType;
    
    //request
    var request: Self.Request!{get set}
    
    //init with request
    init<R where R == Self.Request, R.Point == Self.Element.Point>(request: R)
}
extension FinderDelegateType where Self.Request == FinderSingleRequest<Self.Element.Point> {
    //execute
    mutating public func execute<F: FinderType, S: FinderSourceType where F.Delegate == Self, S.Point == Self.Element.Point>(source: S, finder: F) -> [S.Point] {
        let oe = Self.Element(point:self.request.origin);
        var path:[S.Point] = [self.request.origin];
        self.insert(oe);
        repeat{
            guard let current = self.popBest() else {break;}
            let point = current.point;
            guard point != self.request.goal else {
                path = self.decompressPath(current);
                break;
            }
            let neighbors = source.neighborsOf(point);
            neighbors.forEach{
                finder.explore($0, parent: current, delegate: &self);
            }
        }while true
        return path;
    }
}

extension FinderDelegateType where Self.Request == FinderMultiRequest<Self.Element.Point> {
    //execute
    mutating public func execute<F: FinderType, S: FinderSourceType where F.Delegate == Self, S.Point == Self.Element.Point>(source: S, finder: F) -> [[S.Point]] {
        let oe = Self.Element(point:self.request.origin);
        var paths:[[S.Point]];
        self.insert(oe);
        repeat{
            guard let current = self.popBest() else {break;}
            let point = current.point;
            if let i = self.request.goals.indexOf(point) {
                let path = self.decompressPath(current);
                paths.append(path);
                self.request.goals.removeAtIndex(i);
                guard !self.request.goals.isEmpty else {break;}
            }
            let neighbors = source.neighborsOf(point);
            neighbors.forEach{
                finder.explore($0, parent: current, delegate: &self);
            }
        }while true
        return paths;
    }
}


public struct FinderSingleRequest<T: Hashable>: FinderRequestType {
    public var origin: T;
    public var goal: T;
    init(origin: T, goal: T){
        self.origin = origin;
        self.goal = goal;
    }
}

public struct FinderMultiRequest<T: Hashable>: FinderRequestType {
    public var origin: T;
    public var goals: [T];
    init(origin: T, goals: [T]){
        self.origin = origin;
        self.goals = goals;
    }
}

//MARK: == FinderType ==
public protocol FinderType {
    
    
    //delegate type
    typealias Delegate: FinderDelegateType;
//
//    //explore point
//    func explore<S: FinderSourceType>(point: Self.Delegate.Element.Point, parent: Self.Delegate.Element, source: S, inout delegate: Self.Delegate)
//    
//    //find path, return path from start to goal
////    mutating func find(start: Self.Delegate.Element., goal: S.Point, source: S) -> [S.Point]
////
////    //find paths, return paths from start to goals
////    mutating func find<S: FinderSourceType>(start: S.Point, goals: [S.Point], source: S) -> [[S.Point]]
}



////MARK: == FinderDelegateType ==
//public protocol FinderDelegateType {
//    //queue type
//    typealias Element: FinderElementType;
//    
//    //is termination
//    var isTermination: Bool{get}
//    
//    //find goal
//    mutating func findGoal(point: Self.Element.Point) -> Bool
//    
//    //explore point
//    @warn_unused_result
//    func explore<S: FinderSourceType where S.Point == Self.Element.Point>(point: S.Point, ofParent: Self.Element, source: S) -> Self.Element
//}
//extension FinderDelegateType {
//    
//    //element type
//    typealias E = Self.Element;
//    
//    //point type
//    typealias P = Self.Element.Point;
//    
////    //execute
////    mutating func execute<S: FinderSourceType, Q: FinderQueueType where S.Point == P, Q.Element == E>(origin: E, var goals: [P], inout queue: Q, source: S, findPath: ([P]) -> ()) {
////        var _isComplete = goals.isEmpty;
////        var _findGoal: (P) -> Bool;
////        var _forEachGoal: ((P) -> ()) -> ();
////        
////        if goals.count == 1 {
////            let _goal = goals[0];
////            _forEachGoal = { $0(_goal); }
////            _findGoal = {
////                guard $0 == _goal else{return false;}
////                _isComplete = true;
////                return true;
////            }
////        }
////        else {
////            _forEachGoal = {
////                let fc = $0;
////                goals.forEach{ fc($0); };
////            };
////            _findGoal = {
////                guard let i = goals.indexOf($0) else {return false;}
////                goals.removeAtIndex(i);
////                _isComplete = goals.isEmpty;
////                return true;
////            }
////        }
////        
////        queue.insert(origin);
////        repeat{
////            guard let current = queue.popBest() else {break;}
////            let point = current.point;
////            
////            if _findGoal(point) {
////                let path = queue.decompressPath(current);
////                findPath(path);
////                guard !_isComplete else {return;}
////            }
////            let neighbors = source.neighborsOf(point);
////            neighbors.forEach{
////                let p = $0;
////                guard let visited = queue[p] else{
////                    let ele: Q.Element = self.explore(p, ofParent: current, source: source, forEachGoal: _forEachGoal);
////                    queue.insert(ele);
////                    return;
////                }
////                guard let ele = self.explore(visited, ofParent: current, source: source) else {return;}
////                queue.update(ele);
////            }
////        }while true
////    }
//}
//
//
////MARK: == FinderType ==
//public protocol FinderType {
//    
//    //find path, return path from start to goal
//    mutating func find<S: FinderSourceType>(start: S.Point, goal: S.Point, source: S) -> [S.Point]
//    
//    //find paths, return paths from start to goals
//    mutating func find<S: FinderSourceType>(start: S.Point, goals: [S.Point], source: S) -> [[S.Point]]
//}











