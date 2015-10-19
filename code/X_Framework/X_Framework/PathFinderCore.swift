//
//  PathFinderCore.swift
//  X_Framework
//
//  Created by 173 on 15/10/19.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation
//=================== can be scanned node -> path finder ===================
//MARK: path finder node
protocol PathFinderNode
{
    //set parent
    mutating func setParent(parent:Self?)
    
    //get parent
    func getParent() -> Self?
    
    //backtrace self, return path from start to self
    func backtrace() -> [Self]
}
extension PathFinderNode
{
    func backtrace() -> [Self]
    {
        var chain:[Self] = [];
        var node = self;
        repeat{
            chain.append(node);
            guard let p = node.getParent() else{break;}
            node = p;
        }while true
        return chain.reverse();
    }
}

//========================= path finder protocol ===========================
//MARK: path finder protocol
protocol PathFinderType
{
    typealias _Node: PathFinderNode;
    
    //start tile
    var start:Self._Node?{get}
    
    //goal tile
    var goal:Self._Node?{get}
    
    //return visited list
    var visitedList:[_Node]{get}
    
    //no path, has dead end
    func deadEnd() -> Bool
    
    //grid is goal?
    func isTarget(element: Self._Node) -> Bool
    
    //reset pathFinder
    mutating func reset()
    
    //set _Node visited at tile
    mutating func setVisited(node: Self._Node)
    
    //set _Node closed at tile
    mutating func setClosed(node: Self._Node)
    
    //pop node
    mutating func pop() -> Self._Node
    
    //push node
    mutating func push(node: Self._Node)
    
    //scanning around
    mutating func scanningAround(node: Self._Node)
    
    //find path
    mutating func findPath(pathCallback:([_Node]) -> (), _ visitedCallback:(([_Node]) -> ())?)
}
extension PathFinderType
{
    mutating func findPath(pathCallback:([_Node]) -> (), _ visitedCallback:(([_Node]) -> ())?)
    {
        guard let sg = self.start, let gg = self.goal else{return;}
        
        //reset path finder
        self.reset();
        
        //set start visited and push it into queue
        self.setVisited(sg);
        self.push(sg);
        
        //current node
        var current = sg;
        
        //over: found path or deadend
        defer{
            pathCallback(current.backtrace());
            
            if let _visitedCallback = visitedCallback{
                _visitedCallback(self.visitedList);
            }
        }
        
        //repeat
        repeat{
            // get next current and set it closed and visited
            current = self.pop();
            self.setClosed(current);
            self.setVisited(current);
            
            //found path
            guard !self.isTarget(current) else{break;}
            
            //scanning around
            self.scanningAround(current);
        }while !self.deadEnd()
    }
}
//=========================================================================