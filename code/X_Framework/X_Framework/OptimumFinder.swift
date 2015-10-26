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
    //sub chain
    var subChainable: FinderChainable?{get set}
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
    var h: Int{get}
    
    //weight f = g + h
    var f:Int{get}
    
    //'self' is closed
    var closed:Bool{get set}
    
    //init required
    init(g: Int, h: Int, point: Self._Point)
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
    func getNeighborsOf(point: Self._Point) -> [Self._Point]
    
    //get cost;  < 1 : unwalkable >0:walkable
    func getCostFrom(point: Self._Point, toPoint: Self._Point) -> Int
}


//MARK: finder heuristic
public protocol FinderHeuristic
{
    typealias _Point
    //get heuristic
    func getHeuristic(from: Self._Point, toPoint: Self._Point) -> Int
}

//MARK: OptimumFinder
public protocol OptimumFinder
{
    //element type
    typealias _Element: FinderComparable;
    
    //create element
    func createElement(g:Int, _ h:Int, point: _Point) -> Self._Element
}
//extension internal
extension OptimumFinder
{
    //poing type
    typealias _Point = _Element._Point;
    
    //back trace path
    func backtraceToPath(end: _Element) -> [_Point]
    {
        var element = end;
        var path:[_Point] = [];
        repeat{
            guard let p = element.point else {break;}
            path.append(p);
            guard let ele = element.subChainable as?  _Element else {break;}
            element = ele;
        }while true
        return path;
    }
    
    //create element
    public func createElement(g:Int, _ h:Int, point: Self._Element._Point) -> Self._Element
    {
        return Self._Element(g: g, h: h, point: point);
    }
}
//extension public
extension OptimumFinder
{
    public func find<_DT: FinderDataSource, _HT: FinderHeuristic , _QT:FinderQueue where _DT._Point == _Point, _HT._Point == _Point, _QT.Element == Self._Element>
        (start:_DT._Point, goal: _DT._Point, dataSource: _DT, finderQueue: _QT, heuristic: _HT, completion:([_DT._Point]) -> (), visitation:(([_DT._Point]) -> ())? = nil)
    {
        //create queue
        var queue = finderQueue;

        //append start and set start visited
        var current = self.createElement(0, 0, point: start)
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
                let cost = dataSource.getCostFrom(point, toPoint: n);
                let g = current.g + cost;
                guard let visited = queue.getVisitedElementAt(n) else{
                    //create new element appent it and set it visited
                    let h = heuristic.getHeuristic(point, toPoint: n);
                    var pc = self.createElement(g, h, point: n)
                    pc.closed = false;
                    pc.subChainable = current;
                    queue.appendElement(pc);
                    queue.setPointVisitedOf(pc);
                    continue;
                }

                //if element is not closed, compare neighbor' g with visited' g
                guard !visited.closed && g < visited.g else{ continue; }
                
                //update
                var updateElement = visited;
                updateElement.closed = false;
                updateElement.g = g;
                updateElement.subChainable = current;
                queue.updateElement(updateElement);
                queue.setPointVisitedOf(updateElement);
            }
        }while true
    }
}