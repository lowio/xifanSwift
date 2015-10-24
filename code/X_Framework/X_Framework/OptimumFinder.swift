//
//  OptimumFinder.swift
//  X_Framework
//
//  Created by 173 on 15/10/23.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

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
    
    //init
    init(g: Int, h: Int, point: Self._Point?)
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
    
    //create 'Self'
    static func create() -> Self
}

//optimum finder request
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

//heuristic 
public protocol FinderHeuristic
{
    typealias _Point
    //get heuristic
    func getHeuristic(from: Self._Point, toPoint: Self._Point) -> Int
}

//finder
public protocol OptimumFinder
{
    //map - getNeighbors(point)->point
    //map - getCostFrom(point, toPoint)->point
    
    //huristic
    
    //createQueue()
    
    //completion／visited
}
//extension find use getNeighbors
extension OptimumFinder
{
    func find<_Req: FinderRequest, _Queue: FinderQueue where _Req._Heuristic._Point == _Queue.Element._Point>(request: _Req,
        getNeighbors: (_Req._Heuristic._Point) -> [_Req._Heuristic._Point], getCostFrom: (_Req._Heuristic._Point, _Req._Heuristic._Point) -> Int)
    {
        //create queue
        var queue = _Queue.create();
        
        //append start and set start visited
        var current = _Queue.Element(g: 0, h: 0, point: request.start);
        current.chainFrom = nil;
        current.closed = false;
        queue.appendElement(current);
        queue.setPointVisitedOf(current);
        
        defer{
            print("WARN::======================== completion", __LINE__);
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
            guard point != request.goal else{break;}
            
            //explore neighbors
            let neighbors = getNeighbors(point);
            for n in neighbors
            {
                let g = current.g + getCostFrom(point, n);
                guard let visited = queue.getVisitedElementAt(n) else{
                    //create new element appent it and set it visited
                    let h = request.heuristic.getHeuristic(point, toPoint: n);
                    var pc = _Queue.Element(g: g, h: h, point: n);
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