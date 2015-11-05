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
    
    //MARK: point
    //search start point
    var start: Self.Element.Point{get}
    
    //return neighbor points around point
    func neighborsOf(point: Self.Element.Point) -> [Self.Element.Point]
    
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
}
extension FinderProcessor
{
    //execute
    mutating public func execute() {
        //start element
        guard let startElement = self.exploreSuccessor(start, chainFrom: nil) else {return;}
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
            let neighbors = self.neighborsOf(point);
            neighbors.forEach{
                let n = $0;
                guard let ele = self.exploreSuccessor(n, chainFrom: current) else {return;}
                self.setVisitedElement(ele);
            }
        }while true
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

//MARK: extension where FinderWeightQueue is FinderProcessor
extension FinderWeightQueue where Self: FinderProcessor
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


//MARK: == FinderSingleGoal ==
public protocol FinderSingleGoal
{
    //element type
    typealias Element: FinderComparable;
    
    //goal
    var goal: Self.Element.Point{get}
}
//MARK: extension where FinderSingleGoal is FinderProcessor
extension FinderSingleGoal where Self: FinderProcessor
{
    //termination of element
    public mutating func terminationOf(element: Self.Element) -> Bool {
        guard element.point == self.goal else {return false;}
        return true;
    }
}

//MARK: == FinderMultiGoal ==
public protocol FinderMultiGoal
{
    //element type
    typealias Element: FinderComparable;
    
    //goal
    var goals: [Self.Element.Point]{get set}
}
//MARK: extension where FinderSingleGoal is FinderProcessor
extension FinderMultiGoal where Self: FinderProcessor
{
    //termination of element
    public mutating func terminationOf(element: Self.Element) -> Bool {
        guard let i = (self.goals.indexOf{element.point == $0}) else {return false;}
        //find one
        self.goals.removeAtIndex(i);
        return self.goals.isEmpty;
    }
}

//MARK: == FinderHeuristicType ==
public protocol FinderHeuristicType
{
    //element type
    typealias Element: FinderComparable;
    
    //heuristic h value of point to point
    func heuristicOf(point: Self.Element.Point, _ toPoint: Self.Element.Point) -> CGFloat
}
//MARK: extension where FinderHeuristicType is FinderProcessor, FinderWeightQueue, FinderSingleGoal
extension FinderHeuristicType where Self: FinderProcessor, Self: FinderWeightQueue, Self: FinderSingleGoal
{
    //explore successor point
    @warn_unused_result
    public mutating func exploreSuccessor(point: Self.Element.Point, chainFrom: Self.Element?) -> Self.Element?
    {
        guard let _ = self.getVisitedElement(point) else {
            let ele = Element(g: CGFloat(), h: self.heuristicOf(point, self.goal), point: point, parent: chainFrom);
            self.openList.insert(ele);
            return ele;
        }
        return nil;
    }
}


//MARK: == FinderCostType ==
public protocol FinderCostType
{
    //element type
    typealias Element: FinderComparable;
    
    //cost value of point to point
    func costOf(point: Self.Element.Point, _ toPoint: Self.Element.Point) -> CGFloat
}
//MARK: extension where FinderCostType is FinderProcessor, FinderWeightQueue
extension FinderCostType where Self: FinderProcessor, Self: FinderWeightQueue
{
    //explore successor point
    @warn_unused_result
    public mutating func exploreSuccessor(point: Self.Element.Point, chainFrom: Self.Element?) -> Self.Element?
    {
        guard let _ = self.getVisitedElement(point) else {
            var g:CGFloat = 0;
            if let cf = chainFrom{
                g = cf.g + self.costOf(cf.point, point);
            }
            let ele = Element(g: g, h: 0, point: point, parent: chainFrom as? FinderChainable);
            self.openList.insert(ele);
            return ele;
        }
        return nil;
    }
}

//extension where is FinderCostType, FinderHeuristicType, FinderSingleGoal, FinderWeightQueue
extension FinderProcessor where Self: FinderCostType, Self:FinderHeuristicType, Self: FinderSingleGoal, Self: FinderWeightQueue
{
    //explore successor point
    @warn_unused_result
    public mutating func exploreSuccessor(point: Self.Element.Point, chainFrom: Self.Element?) -> Self.Element?
    {
        var g:CGFloat = 0;
        if let cf = chainFrom{
            g = cf.g + self.costOf(cf.point, point);
        }
        
        guard let visited = self.getVisitedElement(point) else {
            let h = self.heuristicOf(point, self.goal);
            let ele = Element(g: g, h: h, point: point, parent: chainFrom as? FinderChainable);
            self.openList.insert(ele);
            return ele;
        }
        
        guard !visited.isClosed && g < visited.g else{return nil;}
        let ele = Element(g: g, h: visited.h, point: point, parent: chainFrom as? FinderChainable);
        self.updateElement(ele);
        return ele;
    }
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

