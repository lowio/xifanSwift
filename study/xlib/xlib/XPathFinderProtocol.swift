//
//  XPathFinderProtocol.swift
//  xlib
//
//  Created by 173 on 15/9/1.
//  Copyright (c) 2015年 yeah. All rights reserved.
//

import Foundation

//PF = path finder

//path finder node
protocol XPFNode
{
    //parent
    var p:XPFNode?{get set}
    
    //exact cost from start node to self
    var g:CGFloat{get set}
    
    //heuristic estimated cost from self to goal
    var h:CGFloat{get set}
    
    //if scanned
    var closed:Bool{get set}
    
    //f; return g + h
    var f:CGFloat{get}
    
    //if visited; return p != nil;
    var visited:Bool{get}
}

protocol XPFHeuristic
{
    //get heuristic estimated cost fromNode to toNode
    func getHeuristicCost(fromNode fn:XPFNode, toNode tn:XPFNode) -> CGFloat;
}

protocol XPFNeighbors
{
    func pop() -> XPFNode?;
}

//path finder map
protocol XPFMap
{
    //get exact cost between fromNode to toNode
    func getMovementCost(fromNode fn:XPFNode, toNode tn:XPFNode) -> CGFloat;
    
    //get neighbor nodes
    func getNeighbors(atNode n:XPFNode) -> XPFNeighbors;
}

//path finder
protocol XPF
{
    init(heristic:XPFHeuristic);
    
    //get heuristic estimated cost fromNode to toNode
    var heuristic:XPFHeuristic{get set};
    
    //path finder
    func pathFinder(startNode sn:XPFNode, goalNode gn:XPFNode, map:XPFMap, completion:([XPFNode])->());
}