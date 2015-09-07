//
//  TestPathFinder.swift
//  xlib
//
//  Created by 叶贤辉 on 15/9/8.
//  Copyright (c) 2015年 yeah. All rights reserved.
//

import UIKit
import xlib;

//MARK: XPF_Map
struct XPF_Map: XPFMapProtocol
{
//    init(start:T, goal:T)
//    {
//        
//    }
    
    
    
    init()
    {
    }
    
    typealias G = XPF_Grid;
    
    func getHeuristicCost(fromGrid fg:G, toGrid tg:G) -> CGFloat{return 0;}
    
    func getMovementCost(fromGrid fg:G, toGrid tg:G) -> CGFloat{return 1;}
    
    func getNeighbors(atGrid: G) -> [G]{return [];}
}

//path finder test
func pathFindTest()
{
    var map = XPF_Map();
    var s = XPF_Grid();
    var g = XPF_Grid();
    g.x = 10;
    let pf = XPathFinder();
    
    pf.pathFinder(startGrid: s, goalGride: g, map: map){println($0.count)}
}