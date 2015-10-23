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
    
    //point
    var point: Self._Point?{get}
    
    //is closed
    var colsed:Bool{get set}
    
    //create 'Self'
    static func create(point: Self._Point, chainFrom: Self?) -> Self
}

//MARK: optimum finder queue
public protocol FinderQueue
{
    //element Type
    typealias Element: FinderComparable;
    
    //if point is visited return element else return nil
    func getVisited(point: Self.Element._Point) -> Self.Element?
    
    //set element visited
    mutating func setVisited(element: Self.Element)
    
    //pop optimum element
    mutating func popFirst() -> Self.Element?
    
    //appen element
    mutating func append(element: Self.Element)
    
    //update element
    mutating func update(element: Self.Element) -> Bool
    
    //create 'Self'
    static func create() -> Self
}

//optimum finder request
public protocol FinderRequest
{
    //point
    typealias _Point: Hashable;
    
    //start
    var start: Self._Point{get}
    
    //goal
    var goal: Self._Point{get}
}


//finder
public protocol OptimumFinder
{
}
//extension find use getNeighbors
extension OptimumFinder
{
    func find<_Req: FinderRequest, _Queue: FinderQueue where _Req._Point == _Queue.Element._Point>(request: _Req, getNeighbors: (_Req._Point) -> [_Req._Point])
    {
        //create queue
        var queue = _Queue.create();
        
        //append start and set start visited
        var current = _Queue.Element.create(request.start, chainFrom: nil);
        queue.append(current);
        queue.setVisited(current);
        
        defer{
            print("WARN::======================== completion", __LINE__);
        }
        
        //repeat
        repeat{
            guard let _next = queue.popFirst() else {break;}
            
            //set current and close it
            current = _next;
            current.colsed = true;
            //update visited closed state
            queue.setVisited(current);
            
            //compare current point with goal
            guard let point = current.point else {break;}
            guard point != request.goal else{break;}
            
            //explore neighbors
            let neighbors = getNeighbors(point);
            for n in neighbors
            {
                guard let visited = queue.getVisited(n) else{
                    //create new element appent it and set it visited
                    let pc = _Queue.Element.create(n, chainFrom: current);
                    print("WARN::======================== set h and g and parent and point", __LINE__);
                    queue.setVisited(pc);
                    queue.append(pc);
                    continue;
                }
                
                guard !visited.colsed else{ continue; }
                print("WARN::======================== guard new g < visited.g else{continue;} //可以提出此部分用于不同element类型去更新，比如有g的比较g", __LINE__);
                
                var updateElement = visited;
                print("WARN::======================== replace parent and g ", __LINE__);
                updateElement.colsed = false;
                queue.setVisited(updateElement);
                queue.update(updateElement);
            }
        }while true
    }
}