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
    
    
    var grids:XArray2D<Int>;
    
    init()
    {
        let size = 100;
        self.grids = XArray2D<Int>(columns: size);
        for i in 0...size*size-1
        {
            let v = 0;
//            let v = Int(rand()%10) > 3 ?0:1;
            grids.append(v);
        }
//        println(grids);
        
        let a = String(stringInterpolationSegment: grids);
    }
    
    typealias G = XPF_Grid;
    
    func getHeuristicCost(fromGrid fg:G, toGrid tg:G) -> CGFloat
    {
        let x = abs(fg.x - tg.x);
        let y = abs(fg.y - tg.y);
        return CGFloat(x + y);
    }
    
    func getMovementCost(fromGrid fg:G, toGrid tg:G) -> CGFloat{return 1;}
    
    func getNeighbors(atGrid: G) -> [G]
    {
        var neighbors = [G]();
        getNeighbor(&neighbors, grid: atGrid, offsetx: -1, offsetY: 0);
        getNeighbor(&neighbors, grid: atGrid, offsetx: 0, offsetY: 1);
        getNeighbor(&neighbors, grid: atGrid, offsetx: 1, offsetY: 0);
        getNeighbor(&neighbors, grid: atGrid, offsetx: 0, offsetY: -1);
        return neighbors;
    }
    
    private func getNeighbor(inout ns:[G], grid:G, offsetx:Int, offsetY:Int)
    {
        let x = grid.x + offsetx;
        let y = grid.y + offsetY;
        if let v = self.grids[y, x] where v == 0
        {
            var g = XPF_Grid(x, y);
            ns.append(g);
        }
    }
}

//path finder test
func pathFindTest()
{
    
    
    var map = XPF_Map();
    var s = XPF_Grid(0, 0);
    var g = XPF_Grid(6, 6);
    let pf = XPathFinder();
    pf.pathFinder(startGrid: s, goalGride: g, map: map){println($0)}
//    pf.pathFinder(startGrid: s, goalGride: g, map: map){$0}
}