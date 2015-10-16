//
//  PathFinderTest.swift
//  X_Framework
//
//  Created by 173 on 15/9/17.
//  Copyright © 2015年 yeah. All rights reserved.
//

import UIKit

//extension Int:XPathFinderTile2D
//{
//    var movementCost:Int{return 1;}
//    var walkable:Bool{return true;}
//}

extension XPFinderTile2D: CustomStringConvertible
{
    var description:String{
        return "\(movementCost)";
    }
}

func pathFinderTest() {
    
    let size = 50;
    var config = XArray2D<XPFScannable._Tile>(horizontal: size, rows: size);
    for c in 0..<size
    {
        for r in 0..<size
        {
            var v = XPFScannable._Tile.init(c, r);
            v.movementCost = 1;
            config[c, r] = v;
        }
    }
    var xpf = XPFinder2D<XPFScannable>(config: config, algorithm: XPFAlgorithm2D.Manhattan);
    xpf.start = XPFScannable._Tile(3, 3);
    xpf.goal = XPFScannable._Tile(20, 23);
    
    var c = xpf.config;
    
    xpf.findPath({
        for v in $0{
            var temp = v;
            temp.movementCost = 3;
            c[v.x, v.y] = temp;
        }
        print(c);
        print($0.count)
    })
//    {
//        for v in $0{
//            var temp = v;
//            temp.movementCost = 3;
//            c[v.x, v.y] = temp;
//        }
//        print(c);
//        print($0.count)
//    }
    
    
//    XPathFinderType where Self._Scannable._Tile:Hashable, _Scannable:Equatable 这个方法改成通用方法
//    pathFinder方法的where处理一下，XPathFind2DImpl优化一下，
//    改变compare方法后打印visited看看变化
//    此处把visited列表中的节点全部打印
//    load map config json 格式的
//    
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