//
//  PathFinderTest.swift
//  X_Framework
//
//  Created by 173 on 15/9/17.
//  Copyright © 2015年 yeah. All rights reserved.
//

import UIKit

extension XPFinderGrid:Hashable
{
    var hashValue:Int{
        return "\(x), \(y)".hashValue;
    }
}
func ==(lsh:XPFinderGrid, rsh:XPFinderGrid) -> Bool{return lsh.hashValue == rsh.hashValue;}

extension XPFinderNode:Equatable{}
func ==<XPFN:XPFinderNodeType>(lsh:XPFN, rsh:XPFN) -> Bool{return lsh.f == rsh.f;}


extension Int:XPFinderWalkable
{
    var movementCost:Int{return 1;}
    var walkable:Bool{return true;}
}


func pathFinderTest() {
    let xpf = XPFinder();
    
    let size = 50;
    var config = XArray2D<Int>(horizontal: size, rows: size);
    for i in 0..<size*size
    {
        let v = 0;
//      let v = Int(rand()%10) > 3 ?0:1;
        config[i] = v;
    }
    var map = XPFinderMap<XPFinderGrid, Int>(config: config, algorithm: XPFinderAlgorithm.Manhattan)
    map.start = XPFinderGrid(0, 0);
    map.goal = XPFinderGrid(10, 6);
    
    var c = map.config;
    xpf.pathFinder(map, XPFinderNode<XPFinderGrid>.self){
        for v in $0{
            c[v.x, v.y] = 3;
        }
        print(c);
    }
    
    
//    let map = XPF_Map();
//    let s = XPF_Grid(0, 0);
//    let g = XPF_Grid(16, 16);
//    let pf = XPathFinder();
//    //    pf.pathFinder(startGrid: s, goalGride: g, map: map){println("count:\($0.count) \n \($0.description)")}
//    pf.pathFinder(startGrid: s, goalGride: g, map: map){
//        var grids = map.grids;
//        //        println(grids)
//        for v in $1
//        {
//            grids[v.1.y, v.1.x] = 1;
//            
//        }
//        for grid in $0
//        {
//            grids[grid.y, grid.x] = 3;
//        }
//        
//        grids[s.y, s.x] = 4;
//        grids[g.y, g.x] = 5;
//        print(grids);
//    }
}

//MARK: XPF_Map
private struct XPF_Map: XPFMapProtocol
{
    
    
    var grids:XArray2D<Int>;
    
    init()
    {
        let size = 50;
        self.grids = XArray2D<Int>(horizontal: size, rows: size);
        for i in 0..<size*size
        {
            let v = 0;
            //            let v = Int(rand()%10) > 3 ?0:1;
            grids[i] = v;
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
