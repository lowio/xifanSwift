//
//  PathFinderCore.swift
//  X_Framework
//
//  Created by 173 on 15/10/19.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//===============================================================================
//path finder queue type
public protocol PathFinderQueue
{
    //element Type
    typealias _Element;
    
    //append visited element
    mutating func append(visited element: _Element, chainTo parent: _Element?) -> Bool
    
    //pop visited element
    mutating func pop() -> _Element?
    
    //set closed
    mutating func setClosed(element: _Element)
    
    //is closed
    func isClosed(element: _Element) -> Bool
}

//===============================================================================
//path finder option
public protocol PathFinderOption
{
    //element Type
    typealias _Element;

    //start
    var start: _Element?{get}
    
    //goal
    var goal: _Element?{get}
}

//===============================================================================
//path finder PathFinderNeighborsOption
public protocol PathFinderNeighborsOption: PathFinderOption
{
    //get neighbors
    func getNeighbors(around node: _Element) -> [_Element]
}
//===============================================================================
//path finder operator
public protocol PathFinderOprator
{
    //queue type
    typealias _Queue: PathFinderQueue;
    
    //queue
    var queue: _Queue{get set}
    
    //prepare
    mutating func prepare()
    
    //excuting
    mutating func excuting<_OPT: PathFinderOption where _OPT._Element == _Queue._Element>(withElement e: _Queue._Element, useOption opt: _OPT)
    
    //complete
    mutating func completion(at element: _Queue._Element);
    
    //execute
    mutating func execute<_OPT: PathFinderOption where _OPT._Element == _Queue._Element>(opt: _OPT)
}
extension PathFinderOprator where Self._Queue._Element:Equatable
{
    mutating func execute<_OPT: PathFinderOption where _OPT._Element == _Queue._Element>(opt: _OPT)
    {
        guard let start = opt.start, let goal = opt.goal else{return;}
        
        //prepare
        self.prepare();
        
        //append start
        self.queue.append(visited: start, chainTo: nil);
        
        //current node
        var current = start;
        
        //over: found path or deadend
        defer{
            self.completion(at: current)
        }
        
        //repeat
        repeat{
            guard let _next = self.queue.pop() else {break;}
            
            //set current and close it
            current = _next;
            self.queue.setClosed(current);
            
            //find goal
            guard current != start else{break;}
            
            //executing with current
            self.excuting(withElement: current, useOption: opt);
        }while true
    }
}

//=========================================================================
//extension PathFinderOprator: PathFinderNeighbors
extension PathFinderOprator
{
    //excuting with element use option opt
    mutating func excuting<_OPT: PathFinderNeighborsOption where _OPT._Element == _Queue._Element>(withElement e: _Queue._Element, useOption opt: _OPT)
    {
        let neighbors = opt.getNeighbors(around: e);
        neighbors.forEach{
            let neighbor = $0;
            if !self.queue.isClosed(neighbor)
            {
                self.queue.append(visited: neighbor, chainTo: e);
            }
        }
    }
}

//========================= path finder protocol ===========================
////MARK: path finder protocol
//public protocol PathFinderType
//{
//    //path node queue type
////    typealias _Queue: PathFinderQueueType;
//    
//    //path node type typealias
//    typealias _Node: Equatable;
//    
//    //start
//    var start:_Node?{get set}
//    
//    //goal
//    var goal:_Node?{get set}
//    
//    //path chain
//    var path:[_Node]?{get}
//    
//    //prepare for seaching
//    mutating func prepare(start: _Node, _ goal: _Node)
//    
//    //exploring around node
//    mutating func exploring(around node: _Node)
//    
//    //seach complete
//    mutating func completion(at node: _Node)
//    
//    //find path
//    mutating func findPath()
//}
//extension PathFinderType
//{
//    //back trace, return path
//    func backtrace(node: _Node) -> [_Node]
//    {
//        var chain:[_Node] = [];
//        var n = node;
//        repeat{
//            chain.append(n);
//            guard let p = getParentOf(n) else{break;}
//            n = p;
//        }while true
//        return chain.reverse();
//    }
//    
//    mutating func findPath()
//    {
//        guard let sg = self.start, let gg = self.goal else{return;}
//        
//        //reset path finder
//        self.prepare(sg, gg);
//        
//        //set start visited and push it into queue
//        self.setExplored(sg, chainedTo: nil);
//        
//        //current node
//        var current = sg;
//        
//        //over: found path or deadend
//        defer{
//            self.completion(at: current);
//        }
//        
//        //repeat
//        repeat{
//            guard let _next = self.next() else {break;}
//
//            // get next current and set it closed and visited
//            current = _next;
//            self.setClosed(current);
//            
//            //found path
//            guard current != goal else{break;}
//            
//            //exploring around current
//            self.exploring(around: current);
//        }while true
//    }
//}
//
