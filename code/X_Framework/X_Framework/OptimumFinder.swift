//
//  OptimumFinder.swift
//  X_Framework
//
//  Created by 173 on 15/10/23.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//optimum finder element
protocol OptimumFinderElement
{
    //point type
    typealias _Point: Hashable;
    
    //point
    var point: Self._Point?{get}
}

//optimum finder queue
protocol OptimumFinderQueue
{
    //element Type
    typealias Element: OptimumFinderElement;
    
    //return point visit state
    func isVisited(point: Self.Element._Point) -> Bool
    
    //return point close state
    func isClosed(point: Self.Element._Point) -> Bool
    
    //set point visited
    func setVisited(point: Self.Element._Point)
    
    //set point closed
    func setClosed(point: Self.Element._Point)
    
    //pop optimum element
    func popFirst() -> Self.Element?
    
    //appen element
    func append(element: Self.Element)
    
    //update element
    func update(element: Self.Element) -> Bool
}

//optimum finder request
protocol OptimumFinderRequest
{
    //point
    typealias _Point: Hashable;
    
    //start
    var start: Self._Point{get}
    
    //goal
    var goal: Self._Point{get}
}

//finder
protocol OptimumFinder
{
    //execute
    func execute<Req:OptimumFinderRequest>(request: Req)
}