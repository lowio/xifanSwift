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

//MARK: == FinderQueueType ==
public protocol FinderQueueType{
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
}

//MARK: == FinderDelegateType ==
public protocol FinderDelegateType {
    
    //explore visited point's element
    func explore<S: FinderSourceType, E: FinderElementType where S.Point == E.Point>(visited: E, ofParent: E, source: S) -> E?
    
    //explore unvisited point
    func explore<S: FinderSourceType, E: FinderElementType where S.Point == E.Point>(point: S.Point, ofParent: E?, source: S, request: FinderRequest<S.Point>) -> E
}
extension FinderDelegateType {
    //execute
    mutating func execute<S: FinderSourceType, Q: FinderQueueType where S.Point == Q.Element.Point>(var request: FinderRequest<S.Point>, inout queue: Q, source: S) -> [[S.Point]] {
        let element: Q.Element = self.explore(request.origin, ofParent: nil, source: source, request: request);
        queue.insert(element);
        var paths: [[S.Point]] = [];
        repeat{
            guard let current = queue.popBest() else {break;}
            let point = current.point;
            if let flag = request.findGoal(point) {
                let path = queue.decompressPath(current);
                paths.append(path);
                guard !flag else {break;}
            }
            let neighbors = source.neighborsOf(point);
            neighbors.forEach{
                let p = $0;
                guard let visited = queue[p] else{
                    let ele: Q.Element = self.explore(p, ofParent: nil, source: source, request: request);
                    queue.insert(ele);
                    return;
                }
                guard let ele = self.explore(visited, ofParent: current, source: source) else {return;}
                queue.update(ele);
            }
        }while true
        return paths;
    }
}


//MARK: == FinderType ==
public protocol FinderType {
    
    //find path, return path from start to goal
    mutating func find<S: FinderSourceType>(start: S.Point, goal: S.Point, source: S) -> [S.Point]
    
    //find paths, return paths from start to goals
    mutating func find<S: FinderSourceType>(start: S.Point, goals: [S.Point], source: S) -> [[S.Point]]
}

//MARK: == FinderRequest ==
public struct FinderRequest<P: Hashable> {
    //origin
    private var origin: P;
    
    //goals
    private var goals: [P];
    
    //goal
    private var goal: P?
    
    //single goal
    init(origin: P, goal: P)
    {
        self.origin = origin;
        self.goal = goal;
        self.goals = [goal];
    }
    
    //multi goal
    init(origin: P, goals: [P]){
        self.origin = origin;
        self.goals = goals;
        guard goals.count > 1 else {return;}
        self.goal = goals[0];
    }
    
    //multi goal
    init(origin: P, goals: P...) {
        self.init(origin: origin, goals: goals);
    }
    
    //find goal
    public mutating func findGoal(point: P) -> Bool? {
        guard let g = self.goal else {
            guard let i = self.goals.indexOf(point) else {return nil;}
            self.goals.removeAtIndex(i);
            return self.goals.isEmpty;
        }
        guard point == g else {return nil;}
        return true;
    }
    
    //for each goal
    public func forEachGoal(@noescape callback: (P) -> ()) {
        guard let g = self.goal else {
            self.goals.forEach{
                callback($0);
            }
            return;
        }
        callback(g);
    }
}












