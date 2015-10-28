//
//  OptimumFinder.swift
//  X_Framework
//
//  Created by 173 on 15/10/23.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//MARK: optimum finder comparable element
public protocol FinderComparable
{
    //point type
    typealias _Point: Hashable;
    
    //'self' is closed default false
    var isClosed:Bool{get set}
    
    //g score, real cost from start point to 'self' point
    var g: Int{get set}
    
    //h score, hurisctic cost from 'self' point to goal point
    var h: Int{get}
    
    //weight f = g + h
    var f:Int{get}
    
    //point
    var point: Self._Point?{get}
    
    //init required
    init(g: Int, h: Int, point: Self._Point)
}

//MARK: finder heuristic
public protocol FinderHeuristic
{
    typealias _Point
    //get heuristic
    func getHeuristic(from: Self._Point, toPoint: Self._Point) -> Int
}

//MARK: finder datasource
public protocol FinderDataSource
{
    typealias _Point;
    
    //get neighbors
    func getNeighbors(around point: Self._Point) -> [Self._Point]
    
    //get cost from sub point to point
    func getCost(subPoint sp: Self._Point, toPoint tp: Self._Point) -> Int
    
    //point is valid
    func pointIsValid(point: Self._Point) -> Bool
}

//MARK: OptimumFinder
public protocol OptimumFinder
{
    //element type
    typealias Element: FinderComparable;
    
    //priority type
    typealias PQ: PrioritySequence, CollectionType;
    
    //data source type
    typealias DS: FinderDataSource;
    
    //heuristic type
    typealias HT: FinderHeuristic;
    
    //set and get element which at point;
    subscript(point: Self.Element._Point) -> Self.Element?{get set}
    
    //create element, chain to element, isVisited = false;
    func createElement(g:Int, h:Int, point: Self.Element._Point, chainFrom: Self.Element?) -> Self.Element
    
    //completion end, last element
    mutating func completion(end: Self.Element);
}

//extension public
//extension OptimumFinder where Self.PQ.Element == Self.Element, Self.DS._Point == Self.Element._Point, Self.HT._Point == Self.Element._Point
//{
//    //point type
//    private typealias _Point = Self.Element._Point;
//    
//    //find
//    public mutating func find(start: _Point, goal: _Point, dataSource: Self.DS, pQueue: Self.PQ, heuristic: Self.HT)
//    {
//        //check start / goal
//        guard dataSource.pointIsValid(start) && dataSource.pointIsValid(goal) else {return;}
//        
//        //openlist
//        var openList = pQueue;
//        
//        //current element;
//        var current = self.createElement(0, h: heuristic.getHeuristic(start, toPoint: goal), point: start, chainFrom: nil);
//        
//        //set current element visited
//        self[start] = current;
//        //append current
//        openList.append(current);
//        
//        //completion
//        defer{
//            self.completion(current);
//        }
//        
//        //repeat
//        repeat{
//            guard let _next = openList.popFirst() else {break;}
//
//            //current element , current point
//            current = _next;
//            guard let point = current.point else {break;}
//
//            //set current point closed
//            current.isClosed = true;
//            self[point] = current;
//            
//            //compare current point with goal
//            guard point != goal else{break;}
//
//            //explore neighbors
//            let neighbors = dataSource.getNeighbors(around: point);
//            for n in neighbors
//            {
//                let cost = dataSource.getCost(subPoint: point, toPoint: n);
//                let g = current.g + cost;
//                
//                //get element at n
//                guard let visited = self[n] else{
//                    //create new element appent it and set it visited
//                    let h = heuristic.getHeuristic(point, toPoint: n);
//                    let newElement = self.createElement(g, h: h, point: n, chainFrom: current);
//                    self[n] = newElement;
//                    openList.append(newElement);
//                    continue;
//                }
//                
//                guard !visited.isClosed && g < visited.g else {continue;}
//                
//                
//                let updateElement = self.createElement(g, h: visited.h, point: n, chainFrom: current);
//                self[n] = updateElement;
//                openList.append(updateElement);
//                print("前方高能！请注意, 替换append为update===============", __LINE__)
////                let index = openList.indexOf{
//////                    let ele = $0;
//////                    return ele.point! == n;
////                }
//        
//                //update openlist================
//                //openList.updateElement(visited, atIndex: )
//            }
//        }while true
//    }
//}






