//
//  OptimumFinder.swift
//  X_Framework
//
//  Created by 173 on 15/10/23.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//MARK: == FinderChainable ==
public protocol FinderChainable
{
    //parent
    var parent: FinderChainable?{get}
}

//MARK: == FinderComparable ==
public protocol FinderComparable: FinderChainable
{
    //point type
    typealias Point: Hashable;
    
    //'self' is closed default false
    var isClosed:Bool{get set}
    
    //g score, real cost from start point to 'self' point
    var g: CGFloat{get}
    
    //h score, hurisctic cost from 'self' point to goal point
    var h: CGFloat{get}
    
    //weight f = g + h
    var f:CGFloat{get}
    
    //point
    var point: Self.Point{get}
    
    //set parent
    mutating func setParent(parent: FinderChainable, g: CGFloat)
    
    //init
    init(g: CGFloat, h:CGFloat, point: Self.Point, parent: FinderChainable?)
}


//MARK: == FinderProcessor ==
public protocol FinderProcessor
{
    //element type
    typealias Element: FinderComparable;
    
    //request type
    typealias Request: FinderRequestType;
    
    //request
    var request: Self.Request{get}
    
    //MARK: element
    //if element is visited update it, otherwise set it visited
    mutating func setVisitedElement(element: Self.Element)
    
    //pop next element
    mutating func popNext() -> Self.Element?
    
    //MARK: processor
    //termination of element
    mutating func terminationOf(element: Self.Element) -> Bool
    
    //explore successor point
    //if point not visited do 2. otherwise do 1.
    //1.if iscolsed or visited.g is better return nil otherwise update visite.g = g and visited.setParent(chainFrom) and return it
    //2.create element depend on point, insert element and return it.
    @warn_unused_result
    mutating func exploreSuccessor(point: Self.Element.Point, chainFrom: Self.Element?) -> Self.Element?
    
    //execute
    mutating func execute(request: Self.Request)
}
extension FinderProcessor where Self.Element.Point == Self.Request.Point
{
    //execute
    mutating func execute() {
        //start element
        guard let startElement = self.exploreSuccessor(self.request.start, chainFrom: nil) else {return;}
        var current = startElement;
        self.setVisitedElement(current);

        //repeat
        repeat{
            guard let _next = self.popNext() else {break;}
            current = _next;
            let point = current.point;

            current.isClosed = true;
            self.setVisitedElement(current);

            //termination
            guard self.terminationOf(current) else{break;}
            
            //explore neighbors
            let neighbors = self.request.neighborsOf(point);
            neighbors.forEach{
                let n = $0;
                guard let ele = self.exploreSuccessor(n, chainFrom: current) else {return;}
                self.setVisitedElement(ele);
            }
        }while true
    }
}
//MARK: extension where Self: FinderWeightQueue
extension FinderProcessor where Self: FinderWeightQueue
{
    //pop next element
    public mutating func popNext() -> Self.Element?{
        return self.openList.popBest();
    }
    
    //if element is visited update it, otherwise set it visited
    public mutating func setVisitedElement(element: Self.Element)
    {
        self.visitedList[element.point] = element;
    }
    
    //if point was visited return element otherwise return nil;
    func getVisitedElement(point: Self.Element.Point) -> Self.Element? {
        return self.visitedList[point];
    }
}

//MARK: == FinderSingleGoalProcessor ==
public protocol FinderSingleGoalProcessor: FinderProcessor
{
    typealias Request: FinderSingleGoalRequest;
}
extension FinderSingleGoalProcessor where Self.Element.Point == Self.Request.Point
{
    //termination of element
    public mutating func terminationOf(element: Self.Element) -> Bool {
        guard element.point == self.request.goal else {return false;}
        print("WARN::::::: ========== terminationOf")
        return true;
    }
}


//MARK: == FinderMultiGoalsProcessor ==
public protocol FinderMultiGoalsProcessor: FinderProcessor
{
    typealias Request: FinderMiltiGoalRequest;
}
extension FinderMultiGoalsProcessor where Self.Element.Point == Self.Request.Point
{
    //termination of element
    public mutating func terminationOf(element: Self.Element) -> Bool {
        guard let _ = (self.request.goals.indexOf{element.point == $0}) else {return false;}
        print("WARN::::::: ========== terminationOf delete")
        return self.request.goals.isEmpty;
    }
}

//MARK: == FinderWeightQueue ==
public protocol FinderWeightQueue
{
    //element type
    typealias Element: FinderComparable;
    
    //open list
    var openList: BinaryPriorityQueue<Self.Element>{get set}
    
    //visited list
    var visitedList: [Self.Element.Point: Self.Element]{get set}
}
extension FinderWeightQueue
{
    //update openList element
    mutating func updateElement(element: Self.Element)
    {
        print("前方高能！请注意, update===============", __LINE__)
        guard let i = (self.openList.indexOf{return element.h == $0.h}) else {return;}
        self.openList.replaceElement(element, atIndex: i);
    }
}
extension FinderWeightQueue where Self.Element: Equatable
{
    //update openList element
    mutating func updateElement(element: Self.Element)
    {
        print("前方高能！请注意, update===============", __LINE__)
        guard let i = self.openList.indexOf(element) else {return;}
        self.openList.replaceElement(element, atIndex: i);
    }
}

//MARK: ==============FinderRequest=============
//MARK: == FinderRequestType ==
public protocol FinderRequestType
{
    //point type
    typealias Point: Hashable;
    
    //start point
    var start: Self.Point{get}
    
    //neighbors of point
    func neighborsOf(point: Self.Point) -> [Self.Point]
    
    //heuristic h value of point to point
    func heuristicOf(point: Self.Point, _ toPoint: Self.Point) -> CGFloat
    
    //cost value of point to point
    func costOf(point: Self.Point, _ toPoint: Self.Point) -> CGFloat
}

//MARK: == FinderSingleGoalRequest ==
public protocol FinderSingleGoalRequest: FinderRequestType
{
    //goal point
    var goal: Self.Point{get}
}


//MARK: == FinderMiltiGoalRequest ==
public protocol FinderMiltiGoalRequest: FinderRequestType
{
    //goals point
    var goals: [Self.Point]{get}
}







/**
one - one: 
    greedy best first                   h               1
    A*                                  g + h           1
one - more, or more - one
    breadth first : unweight            nil             n
    dijkstra's algorithm: weight        g               n
    bellman-ford
more - more
    floyd-warshall
    johnson's algorithm

**/

