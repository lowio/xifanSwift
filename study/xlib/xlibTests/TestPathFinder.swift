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
        let size = 50;
        self.grids = XArray2D<Int>(columns: size);
        for _ in 0...size*size-1
        {
            let v = 0;
//            let v = Int(rand()%10) > 3 ?0:1;
            grids.append(v);
        }
//        println(grids);
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
            let g = XPF_Grid(x, y);
            ns.append(g);
        }
    }
}

//path finder test
func pathFindTest()
{
    
    
    let map = XPF_Map();
    let s = XPF_Grid(0, 0);
    let g = XPF_Grid(16, 16);
    let pf = XPathFinder();
//    pf.pathFinder(startGrid: s, goalGride: g, map: map){println("count:\($0.count) \n \($0.description)")}
    pf.pathFinder(startGrid: s, goalGride: g, map: map){
        var grids = map.grids;
//        println(grids)
        for v in $1
        {
            grids.update(1, atColumn: v.1.y, atRow: v.1.x);
        }
        for grid in $0
        {
            grids.update(3, atColumn: grid.y, atRow: grid.x)
        }
        
        grids.update(4, atColumn: s.y, atRow: s.x)
        grids.update(5, atColumn: g.y, atRow: g.x)
        
        print(grids);
    }
}