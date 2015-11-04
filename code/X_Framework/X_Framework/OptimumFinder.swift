//
//  OptimumFinder.swift
//  X_Framework
//
//  Created by 173 on 15/10/23.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//MARK: optimum finder comparable element
public protocol FinderComparable: Comparable
{
    //point type
    typealias _Point: Hashable;
    
    //'self' is closed default false
    var isClosed:Bool{get set}
    
    //g score, real cost from start point to 'self' point
    var g: CGFloat{get set}
    
    //h score, hurisctic cost from 'self' point to goal point
    var h: CGFloat{get}
    
    //weight f = g + h
    var f:CGFloat{get}
    
    //point
    var point: Self._Point{get}
}

//MARK: OptimumFinder
public protocol OptimumFinder
{
    //element type
    typealias Element: FinderComparable;
    
    //get neighbors
    func getNeighbors(around point: Self.Element._Point) -> [Self.Element._Point]
    
    //get cost from sub point to point
    func getCost(subPoint sp: Self.Element._Point, toPoint tp: Self.Element._Point) -> CGFloat
    
    //point is valid
    func pointIsValid(point: Self.Element._Point) -> Bool
    
    //get heuristic
    func getHeuristic(from: Self.Element._Point, toPoint: Self.Element._Point) -> CGFloat
    
    
    
    //create element
    func createElement(g: CGFloat, h:CGFloat, point: Self.Element._Point, chainFrom: Self.Element?) -> Self.Element
    
    //get visited element of point
    func visitedElementOf(point: Self.Element._Point) -> Self.Element?
    
    //set element visited
    mutating func visitedElement(element: Self.Element)
    
    //set element closed
    mutating func closedElement(element: Self.Element)
    
    //pop next element
    mutating func popNext() -> Self.Element?
    
    //insert element
    mutating func insert(element: Self.Element)
    
    //update visited element
    mutating func updateVisited(element: Self.Element)
    
    
    //completion
    mutating func completion(endElement: Self.Element)
}
extension OptimumFinder
{
    mutating public func find(start: Self.Element._Point, goal: Self.Element._Point)
    {
        //check start / goal
        guard self.pointIsValid(start) && self.pointIsValid(goal) else {return;}

        //current element;
        var current = self.createElement(0, h: self.getHeuristic(start, toPoint: goal), point: start, chainFrom: nil);

        //set current element visited
        self.visitedElement(current);
        //append current
        self.insert(current);
        
        defer{
            self.completion(current);
        }

        //repeat
        repeat{
            guard let _next = self.popNext() else {break;}

            //current element , current point
            current = _next;
            let point = current.point;

            //set current point closed
            current.isClosed = true;
            self.closedElement(current);

            //compare current point with goal
            guard point != goal else{break;}

            //explore neighbors
            let neighbors = self.getNeighbors(around: point);
            neighbors.forEach{
                let n = $0;
                let cost = self.getCost(subPoint: point, toPoint: n);
                let g = current.g + cost;
                
                guard let visited = self.visitedElementOf(n) else{
                    let h = self.getHeuristic(point, toPoint: n);
                    let newElement = self.createElement(g, h: h, point: n, chainFrom: current);
                    //set parent
                    self.visitedElement(newElement);
                    self.insert(newElement);
                    return;
                }
                
                guard !visited.isClosed && g < visited.g else {return;}
                let updateElement = self.createElement(g, h: visited.h, point: n, chainFrom: current);
                self.visitedElement(updateElement);
                self.updateVisited(updateElement);
                print("前方高能！请注意, update===============", __LINE__)
            }
        }while true
    }
}





