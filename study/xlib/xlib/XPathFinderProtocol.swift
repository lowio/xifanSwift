//
//  XPathFinderProtocol.swift
//  xlib
//
//  Created by 173 on 15/9/1.
//  Copyright (c) 2015年 yeah. All rights reserved.
//

import UIKit

//PF = path finder

//MARK: map grid protocol
protocol XPFGridProtocol
{
    var x:Int{get set};
    var y:Int{get set};
    //exact cost from start node to self
    var g:CGFloat{get set}
    
    //heuristic estimated cost from self to goal
    var h:CGFloat{get set}
    
    //f; return g + h
    var f:CGFloat{get}
    
    //parent
    var p:XPFGridProtocol?{get set};
    var isClosed:Bool{get set}
    var isOpened:Bool{get set}
}

//MARK: map protocol
protocol XPFMapProtocol
{
    typealias G:XPFGridProtocol;
    
    //get heuristic estimated cost fromGrid to toGrid
    func getHeuristicCost(fromGrid fg:G, toGrid tg:G) -> CGFloat;
    
    //get exact cost between fromGrid to toGrid
    func getMovementCost(fromGrid fg:G, toGrid tg:G) -> CGFloat;
    
    //get neighbor nodes
    func getNeighbors(atGrid: G) -> [G];
}

//path finder protocol
protocol XPFProtocol
{
    //path finder
    func pathFinder<M:XPFMapProtocol where M.G:Hashable>(startGrid sg:M.G, goalGride gg:M.G, map:M, completion:([M.G])->());
//    func pathFinder<M:XPFMapProtocol, G:XPFGridProtocol where G:Hashable, M.G == G>(startGrid sg:G, goalGride gg:G, map:M, completion:([G])->());
}