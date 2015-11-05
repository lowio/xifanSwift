//
//  OptimumFinderImpl.swift
//  X_Framework
//
//  Created by 叶贤辉 on 15/10/23.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//MARK: == FinderElement ==
public struct FinderElement<T: Hashable>{
    //'self' is closed default false
    public var isClosed:Bool = false;
    
    //chain from
    public private (set) var parent: FinderChainable?;
    
    //weight f = g + h
    public private (set) var g, h, f:CGFloat;
    
    //point
    public private (set) var point: T;
    
    //init
    public init(g: CGFloat, h:CGFloat, point: T, parent: FinderChainable?)
    {
        self.g = g;
        self.h = h;
        self.f = g + h;
        self.point = point;
        self.parent = parent;
    }
}
extension FinderElement: FinderComparable{
    mutating public func setParent(parent: FinderChainable, g: CGFloat) {
        self.parent = parent;
        self.g = g;
        self.f = self.g + self.h;
    }
}
extension FinderElement: FinderChainable{}
extension FinderElement: Equatable{}
public func ==<T: Hashable>(lsh: FinderElement<T>, rsh: FinderElement<T>) -> Bool {return lsh == rsh;}



//MARK: == GreedyBestFirstFinder ==
public struct GreedyBestFirstFinder<T: Hashable>
{
    //search start point
    public private (set) var start: T;
    
    //search goal point
    public private (set) var goal: T;
    
    //queue
    public var openList: BinaryPriorityQueue<Element>;
    
    //dic
    public var visitedList: [T: Element];
    
    public init(_ start: T, _ goal: T)
    {
        self.start = start;
        self.goal = goal;
        self.openList = BinaryPriorityQueue<Element>{return $0.h < $1.h;}
        self.visitedList = [:];
    }
}
//MARK: extension FinderWeightQueue
extension GreedyBestFirstFinder: FinderWeightQueue{}
//MARK: extension FinderSingleGoal
extension GreedyBestFirstFinder: FinderSingleGoal{}
//MARK: extension FinderHeuristicType
extension GreedyBestFirstFinder: FinderHeuristicType{
    
    //heuristic h value of point to point
    public func heuristicOf(point: T, _ toPoint: T) -> CGFloat
    {
        return 0;
    }
}
//MARK: extension FinderProcessor
extension GreedyBestFirstFinder: FinderProcessor {
    
    public typealias Element = FinderElement<T>;
    
    //return neighbor points around point
    public func neighborsOf(point: T) -> [T] {
        return []
    }
}


//MARK: == DijkstraFinder ==
public struct DijkstraFinder<T: Hashable>
{
    //search start point
    public private (set) var start: T;
    
    //search goal point
    public var goals: [T];
    
    //queue
    public var openList: BinaryPriorityQueue<Element>;
    
    //dic
    public var visitedList: [T: Element];
    
    public init(_ start: T, _ goals: T...)
    {
        self.start = start;
        self.goals = goals;
        self.openList = BinaryPriorityQueue<Element>{return $0.g < $1.g;}
        self.visitedList = [:];
    }
}
//MARK: extension FinderWeightQueue
extension DijkstraFinder: FinderWeightQueue{}
//MARK: extension FinderSingleGoal
extension DijkstraFinder: FinderMultiGoal{}
//MARK: extension FinderCostType
extension DijkstraFinder: FinderCostType{
    //cost value of point to point
    public func costOf(point: T, _ toPoint: T) -> CGFloat
    {
        return 0;
    }
}
//MARK: extension FinderProcessor
extension DijkstraFinder: FinderProcessor {
    
    public typealias Element = FinderElement<T>;
    
    //return neighbor points around point
    public func neighborsOf(point: T) -> [T] {
        return []
    }
}

//MARK: == AstarFinder ==
public struct AstarFinder<T: Hashable>
{
    //search start point
    public private (set) var start: T;
    
    //search goal point
    public private (set) var goal: T;
    
    //queue
    public var openList: BinaryPriorityQueue<Element>;
    
    //dic
    public var visitedList: [T: Element];
    
    public init(_ start: T, _ goal: T)
    {
        self.start = start;
        self.goal = goal;
        self.openList = BinaryPriorityQueue<Element>{return $0.h < $1.h;}
        self.visitedList = [:];
    }
}
//MARK: extension FinderWeightQueue
extension AstarFinder: FinderWeightQueue{}
//MARK: extension FinderSingleGoal
extension AstarFinder: FinderSingleGoal{}
//MARK: extension FinderHeuristicType
extension AstarFinder: FinderHeuristicType{
    
    //heuristic h value of point to point
    public func heuristicOf(point: T, _ toPoint: T) -> CGFloat
    {
        return 0;
    }
}
//MARK: extension FinderCostType
extension AstarFinder: FinderCostType{
    //cost value of point to point
    public func costOf(point: T, _ toPoint: T) -> CGFloat
    {
        return 0;
    }
}
//MARK: extension FinderProcessor
extension AstarFinder: FinderProcessor {
    
    public typealias Element = FinderElement<T>;
    
    //return neighbor points around point
    public func neighborsOf(point: T) -> [T] {
        return []
    }
}
