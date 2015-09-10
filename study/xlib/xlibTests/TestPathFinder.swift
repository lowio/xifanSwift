//
//  TestPathFinder.swift
//  xlib
//
//  Created by 叶贤辉 on 15/9/8.
//  Copyright (c) 2015年 yeah. All rights reserved.
//

import UIKit
import xlib;

//extension XArray2D
//{
//    var description:String{
//        let rs = rows;
//        let cs = columns;
//        var desc = "";
//        for r in 0..<rs
//        {
//            var l = "";
//            var s = "";
//            for c in 0..<cs
//            {
//                if let element = self[c, r] as? Printable
//                {
//                    l += "_ ";
//                    s += "\(element.description)|";
//                }
//            }
//            desc += l + "\n";
//            desc += s + "\n";
//        }
//        return desc;
//    }
//}

//MARK: XPF_Map
struct XPF_Map: XPFMapProtocol
{
    
    
    var grids:XArray2D<Int>;
    
    init()
    {
        self.grids = XArray2D<Int>(columns: 10);
        for i in 0...99
        {
            grids.append(Int(arc4random())%1);
        }
        grids[100] = nil;
        println(grids);
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