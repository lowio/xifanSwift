//
//  OptimumFinder.swift
//  X_Framework
//
//  Created by 173 on 15/10/23.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation
//MARK: finder chainable type
public protocol FinderChainable
{
    //chain from
    var chainFrom: FinderChainable?{get set}
}

//MARK: optimum finder comparable element
public protocol FinderComparable: FinderChainable
{
    //point type
    typealias _Point: Hashable;
    
    //point
    var point: Self._Point?{get}
    
    //g score, real cost from start point to 'self' point
    var g: Int{get set}
    
    //h score, hurisctic cost from 'self' point to goal point
    var h: Int{get set}
    
    //weight f = g + h
    var f:Int{get}
    
    //'self' is closed
    var closed:Bool{get set}
}

//MARK: optimum finder queue
public protocol FinderQueue
{
    //element Type
    typealias Element: FinderComparable;
    
    //if point is visited return element else return nil
    func getVisitedElementAt(point: Self.Element._Point) -> Self.Element?
    
    //set element's point closed and update it in 'Self'
    mutating func setPointClosedOf(element: Self.Element)
    
    //set element's point visited and update it in 'Self'
    mutating func setPointVisitedOf(element: Self.Element)
    
    //pop optimum element
    mutating func popFirstElement() -> Self.Element?
    
    //appen element
    mutating func appendElement(element: Self.Element)
    
    //update element
    mutating func updateElement(element: Self.Element) -> Bool
    
    //all visited point
    func allVisitedPoints() -> [Self.Element._Point]
}

//MARK: finder datasource
public protocol FinderDataSource
{
    typealias _Point;
    
    //get neighbors
    func getNeighborsOf(point: Self._Point) -> [_Point]
    
    //get cost
    func getCostFrom(point: Self._Point, toPoint: Self._Point) -> Int
}

//MARK: finder request
public protocol FinderRequest
{
    
    //heuristic type
    typealias _Heuristic: FinderHeuristic
    
    //start
    var start: Self._Heuristic._Point{get}
    
    //goal
    var goal: Self._Heuristic._Point{get}
    
    //heurisitc
    var heuristic: Self._Heuristic{get}
}

//MARK: finder heuristic
public protocol FinderHeuristic
{
    typealias _Point
    //get heuristic
    func getHeuristic(from: Self._Point, toPoint: Self._Point) -> Int
}

//finder
public protocol OptimumFinder
{
    //FinderRequest/ FinderQueue/ FinderDataSource
    
    //path finder queue type
    typealias _Queue: FinderQueue;
    
    //path finder request type
    typealias _Request: FinderRequest;
    
    //path data source type
    typealias _DataSource: FinderDataSource;
    
    //create element
    func createElement(g: Int, h: Int, point: Self._Queue.Element._Point) -> Self._Queue.Element
    
    //create queue
    func createQueue() -> Self._Queue
    
    //backtrace path
    func backtraceToPath(end: Self._Queue.Element) -> [Self._Queue.Element._Point]
}
extension OptimumFinder
{
    func backtraceToPath(end: Self._Queue.Element) -> [Self._Queue.Element._Point]
    {
        var element = end;
        var path:[Self._Queue.Element._Point] = [];
        repeat{
            guard let p = element.point else {break;}
            path.append(p);
            guard let ele = element.chainFrom as? _Queue.Element else {break;}
            element = ele;
        }while true
        return path;
    }
}
//extension find use getNeighbors
extension OptimumFinder where Self._Request._Heuristic._Point == Self._Queue.Element._Point, Self._Queue.Element._Point == Self._DataSource._Point
{
    func find(request: _Request, dataSource: _DataSource, completion:([_DataSource._Point]) -> (), visitation:(([_DataSource._Point]) -> ())? = nil)
    {
        let start = request.start;
        let goal = request.goal;
        let heuristic = request.heuristic;
        
        //create queue
        var queue = self.createQueue();
        
        //append start and set start visited
        var current = self.createElement(0, h: 0, point: start)
        current.chainFrom = nil;
        current.closed = false;
        queue.appendElement(current);
        queue.setPointVisitedOf(current);
        
        defer{
            let path = self.backtraceToPath(current);
            completion(path);
            if let _visitation = visitation
            {
                let visitedPoints = queue.allVisitedPoints();
                _visitation(visitedPoints);
            }
        }
        
        //repeat
        repeat{
            guard let _next = queue.popFirstElement() else {break;}
            
            //current element , current point
            current = _next;
            guard let point = current.point else {break;}
            
            //set current's point closed
            current.closed = true;
            queue.setPointClosedOf(current);
            
            //compare current point with goal
            guard point != goal else{break;}
            
            //explore neighbors
            let neighbors = dataSource.getNeighborsOf(point);
            for n in neighbors
            {
                let g = current.g + dataSource.getCostFrom(point, toPoint: n);
                guard let visited = queue.getVisitedElementAt(n) else{
                    //create new element appent it and set it visited
                    let h = heuristic.getHeuristic(point, toPoint: n);
                    var pc = self.createElement(g, h: h, point: n)
                    pc.closed = false;
                    pc.chainFrom = current;
                    queue.appendElement(pc);
                    queue.setPointVisitedOf(pc);
                    continue;
                }
                
                //if element is not closed, compare neighbor' g with visited' g
                guard !visited.closed && g < visited.g else{ continue; }
                
                //update
                var updateElement = visited;
                updateElement.g = g;
                updateElement.closed = false;
                updateElement.chainFrom = current;
                queue.updateElement(updateElement);
                queue.setPointVisitedOf(updateElement);
            }
        }while true
    }
}